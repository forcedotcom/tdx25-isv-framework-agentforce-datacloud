const fs = require("fs");
const path = require("path");
const { faker } = require("@faker-js/faker");
const fastcsv = require("fast-csv");
const { v4: uuidv4 } = require("uuid");

function createApplianceMap(applianceFiles) {
  const typeToSerialsMap = {};
  applianceFiles.forEach((filePath) => {
    const jsonData = JSON.parse(fs.readFileSync(filePath, "utf8"));

    jsonData.records.forEach((record) => {
      const type = record.mvpbo2__Type__c;
      const serial = record.mvpbo2__Mfg_Serial__c;

      if (!typeToSerialsMap[type]) {
        typeToSerialsMap[type] = [];
      }

      typeToSerialsMap[type].push(serial);
    });
  });
  return typeToSerialsMap;
}

function generateDummyData(applianceName, columnConfig, outputFolder, options = {}) {
  const {
    keyAttribute = null,
    numRecords = 0,
    timestampMode = "same",
    baseDate = new Date(new Date().setUTCHours(0, 0, 0, 0)),
    degradationDays = 30,
    degradationColumns = [],
    degradationProportion = 0.1,
    timespanDays = 30,
    outputFormat = "csv" 
  } = options;
  
  const columnsConfig = columnConfig[applianceName];

  const generateTimestamp = (day) => {
    const relativeDate = new Date(baseDate);
    relativeDate.setDate(baseDate.getDate() + day);
    return relativeDate.toISOString();
  };

  const generateValue = (config, day, applyDegradation) => {
    if (Array.isArray(config)) {
      return faker.helpers.arrayElement(config);
    } else if (typeof config === "object" && config.range) {
      const { min, max, outlierProbability = 0.1, type = "int" } = config.range;

      let value;
      if (Math.random() < outlierProbability) {
        const outlierOffset =
          Math.random() < 0.5 ? -(max - min) / 2 : (max - min) / 2;
        value =
          type === "int"
            ? faker.number.int({
                min: min + outlierOffset,
                max: max + outlierOffset
              })
            : faker.number.float({
                min: min + outlierOffset,
                max: max + outlierOffset,
                precision: 0.01
              });
      } else {
        value =
          type === "int"
            ? faker.number.int({ min, max })
            : faker.number.float({ min, max, precision: 0.01 });
      }

      // Apply degradation factor if applicable
      if (applyDegradation && degradationColumns.includes(config.columnName)) {
        const degradationFactor = day / degradationDays;
        value = Math.min(max, value + (max - min) * degradationFactor);
      }
      return value;
    } else {
      console.error(`Invalid configuration for column ${config.columnName}`);
      return null;
    }
  };

  for (let day = 0; day < timespanDays; day++) {
    const data = [];
    const currentDate = new Date(baseDate);
    currentDate.setDate(baseDate.getDate() + day);
    const dateString = currentDate.toISOString().split("T")[0];

    if (keyAttribute && columnsConfig[keyAttribute]) {
      const colConfigWithoutKey = { ...columnsConfig };
      delete colConfigWithoutKey[keyAttribute];
      for (let i = 0; i < columnsConfig[keyAttribute].length; i++) {
        const record = { id: uuidv4() }; // Add unique ID
        const applyDegradation = Math.random() < degradationProportion;
        for (const columnName in colConfigWithoutKey) {
          const config = colConfigWithoutKey[columnName];
          config.columnName = columnName; // Add column name to config for reference
          record[columnName] = generateValue(config, day, applyDegradation);
        }
        record[keyAttribute] = columnsConfig[keyAttribute][i];
        record.timestamp = generateTimestamp(day);
        data.push(record);
      }
    } else if (numRecords > 0) {
      for (let i = 0; i < numRecords; i++) {
        const record = { id: uuidv4() }; // Add unique ID
        const applyDegradation = Math.random() < degradationProportion;
        for (const columnName in columnsConfig) {
          const config = columnsConfig[columnName];
          config.columnName = columnName; // Add column name to config for reference
          record[columnName] = generateValue(config, day, applyDegradation);
        }
        record.timestamp = generateTimestamp(day);
        data.push(record);
      }
    }

    const applianceFolder = path.join(outputFolder, applianceName.toLowerCase());
    if (!fs.existsSync(applianceFolder)) {
      fs.mkdirSync(applianceFolder, { recursive: true });
    }

    const outputFilePath = path.join(applianceFolder, `${applianceName}_data_${dateString}.${outputFormat}`);
    if (outputFormat === "json") {
      fs.writeFileSync(outputFilePath, JSON.stringify(data, null, 2));
    } else if (outputFormat === "csv") {
      const ws = fs.createWriteStream(outputFilePath);
      fastcsv
        .write(data, { headers: true })
        .pipe(ws);
    }
    console.log(`Generated ${data.length} dummy records for ${dateString} and saved to ${outputFilePath}`);
  }
}

// Define the file paths
const applianceFiles = [
  path.join(__dirname, "../../data/salesforce/Appliance__c1.json"),
  path.join(__dirname, "../../data/salesforce/Appliance__c2.json"),
  path.join(__dirname, "../../data/salesforce/Appliance__c3.json")
];

const applianceMap = createApplianceMap(applianceFiles);

const columnConfig = {
  dishwasher: {
    SerialNumber: applianceMap["Dishwasher"], // Array of values
    WaterUsage: {range: {min:2, max:6, type:"float", outlierProbability:0.05}},
    MaxWaterTemp: {range: {min:110, max:150, type:"int", outlierProbability:0.05}},
    MinWaterTemp: {range: {min:110, max:125, type:"int", outlierProbability:0.05}},
    DryingTemp: {range: {min:140, max:160, type:"int", outlierProbability:0.05}},
    MaxDecibels: {range: {min:40, max:55, type:"int", outlierProbability:0.05}},
    EnergyConsumption: {range: {min:0.5, max:1.5, type:"float", outlierProbability:0.05}}
  },
  hvac: {
    SerialNumber: applianceMap["HVAC"], // Array of values
    TemperatureAccuracy: {
      range: { min: -2, max: 2, outlierProbability: 0.05, type: "float" }
    },
    Airflow: {
      range: { min: 900, max: 1800, outlierProbability: 0.05, type: "int" }
    },
    MaxDecibels: {
      range: { min: 0, max: 60, outlierProbability: 0.05, type: "int" }
    },
    EnergyConsumption: {
      range: { min: 3, max: 4.5, outlierProbability: 0.05, type: "float" }
    },
    FilterDifferential: {
      range: { min: 0.1, max: 0.3, outlierProbability: 0.05, type: "float" }
    },
    RefrigerantLevels: {
      range: { min: 0, max: 1, outlierProbability: 0.05, type: "float" }
    },
    DuctPressure: {
      range: { min: 0.3, max: 0.8, outlierProbability: 0.05, type: "float" }
    }
  },
  refrigerator: {
    SerialNumber: applianceMap["Refrigerator"], // Array of values
    FridgeTemperature: {
      range: { min: 35, max: 40, outlierProbability: 0.05, type: "float" }
    },
    FreezerTemperature: {
      range: { min: 0, max: 5, outlierProbability: 0.05, type: "float" }
    },
    MaxDecibels: {
      range: { min: 0, max: 40, outlierProbability: 0.05, type: "int" }
    },
    EnergyConsumption: {
      range: { min: 0.5, max: 1.5, outlierProbability: 0.01, type: "float" }
    },
    DefrostCycleFrequency: {
      range: { min: 6, max: 8, outlierProbability: 0.05, type: "int" }
    }
  },
  washer: {
    SerialNumber: applianceMap["Washer"], // Array of values
    WaterUsage: {
      range: { min: 15, max: 20, outlierProbability: 0.01, type: "int" }
    },
    MaxWaterTemperature: {
      range: { min: 40, max: 140, outlierProbability: 0.05, type: "int" }
    },
    SpinSpeed: {
      range: { min: 600, max: 1400, outlierProbability: 0.05, type: "int" }
    },
    MaxDecibels: {
      range: { min: 50, max: 70, outlierProbability: 0.05, type: "int" }
    },
    EnergyConsumption: {
      range: { min: 0.2, max: 1.5, outlierProbability: 0.05, type: "float" }
    },
    VibrationLevel: {
      range: { min: 0.5, max: 1.0, outlierProbability: 0.05, type: "float" }
    }
  }
};

const parentFolder = "data/s3/";
generateDummyData("hvac", columnConfig, parentFolder, {
  keyAttribute: "SerialNumber",
  degradationDays: 30,
  degradationColumns: ["FilterDifferential", "EnergyConsumption"],
  degradationProportion: 0.1,
  timespanDays: 2,
  outputFormat: "csv" // Specify output format as CSV
});

generateDummyData("refrigerator", columnConfig, parentFolder, {
  keyAttribute: "SerialNumber",
  degradationDays: 30,
  degradationColumns: ["FreezerTemperature", "EnergyConsumption"],
  degradationProportion: 0.1,
  timespanDays: 2,
  outputFormat: "csv" // Specify output format as CSV
});

generateDummyData("dishwasher", columnConfig, parentFolder, {
  keyAttribute: "SerialNumber",
  degradationDays: 30,
  degradationColumns: ["MaxDecibels", "EnergyConsumption"],
  degradationProportion: 0.1,
  timespanDays: 2,
  outputFormat: "csv" // Specify output format as CSV
});

generateDummyData("washer", columnConfig, parentFolder, {
  keyAttribute: "SerialNumber",
  degradationDays: 30,
  degradationColumns: ["EnergyConsumption", "VibrationLevel"],
  degradationProportion: 0.1,
  timespanDays: 2,
  outputFormat: "csv" // Specify output format as CSV
});