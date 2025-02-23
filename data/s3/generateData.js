const fs = require("fs");
const path = require("path");
const { faker } = require("@faker-js/faker");

function createApplianceMap(applianceFiles) {
  const typeToSerialsMap = {};
  applianceFiles.forEach((filePath) => {
    const jsonData = JSON.parse(fs.readFileSync(filePath, "utf8"));

    jsonData.records.forEach((record) => {
      const type = record.Type__c;
      const serial = record.Mfg_Serial__c;

      if (!typeToSerialsMap[type]) {
        typeToSerialsMap[type] = [];
      }

      typeToSerialsMap[type].push(serial);
    });
  });
  return typeToSerialsMap;
}

function generateDummyData(columnsConfig, outputFilePath, options = {}) {
  const data = [];
  const {
    keyAttribute = null,
    numRecords = 0,
    timestampMode = "same",
    baseDate = new Date(new Date().setUTCHours(0, 0, 0, 0))
  } = options;

  const generateTimestamp = () => {
    if (timestampMode === "same") {
      return baseDate.toISOString();
    } else if (timestampMode === "relative") {
      const relativeDate = new Date(baseDate);
      const hours = faker.number.int({ min: 0, max: 23 });
      const minutes = faker.number.int({ min: 0, max: 59 });
      relativeDate.setUTCHours(hours, minutes, 0, 0);
      return relativeDate.toISOString();
    }
    return new Date().toISOString();
  };

  const generateValue = (config) => {
    if (Array.isArray(config)) {
      return faker.helpers.arrayElement(config);
    } else if (typeof config === "object" && config.range) {
      const { min, max, outlierProbability = 0.1, type = 'int' } = config.range;

      let value;
      if (Math.random() < outlierProbability) {
        const outlierOffset = Math.random() < 0.5 ? -(max - min) / 2 : (max - min) / 2;
        value = type === 'int'
          ? faker.number.int({ min: min + outlierOffset, max: max + outlierOffset })
          : faker.number.float({ min: min + outlierOffset, max: max + outlierOffset, precision: 0.01 });
      } else {
        value = type === 'int'
          ? faker.number.int({ min, max })
          : faker.number.float({ min, max, precision: 0.01 });
      }
      return value;
    } else {
      console.error(`Invalid configuration for column ${columnName}`);
      return null;
    }
  };

  if (keyAttribute && columnsConfig[keyAttribute]) {
    const colConfigWithoutKey = { ...columnsConfig };
    delete colConfigWithoutKey[keyAttribute];

    for (let i = 0; i < columnsConfig[keyAttribute].length; i++) {
      const record = {};
      for (const columnName in colConfigWithoutKey) {
        const config = colConfigWithoutKey[columnName];
        record[columnName] = generateValue(config);
      }
      record[keyAttribute] = columnsConfig[keyAttribute][i];
      record.timestamp = generateTimestamp();
      data.push(record);
    }
  } else if (numRecords > 0) {
    for (let i = 0; i < numRecords; i++) {
      const record = {};
      for (const columnName in columnsConfig) {
        const config = columnsConfig[columnName];
        record[columnName] = generateValue(config);
      }
      record.timestamp = generateTimestamp();
      data.push(record);
    }
  }
  fs.writeFileSync(outputFilePath, JSON.stringify(data, null, 2));
  console.log(
    `Generated ${data.length} dummy records and saved to ${outputFilePath}`
  );
}

// Define the file paths
const applianceFiles = [
  path.join(__dirname, "../../data/salesforce/Appliance__c1.json"),
  path.join(__dirname, "../../data/salesforce/Appliance__c2.json"),
  path.join(__dirname, "../../data/salesforce/Appliance__c3.json")
];

const applianceMap = createApplianceMap(applianceFiles);
// print keys in applianceMap

// Example usage:
const dishwasherColConfig = {
  "Serial Number": applianceMap["Dishwasher"], // Array of values
  Temperature: { range: { min: 68, max: 78, type: 'float' } }, // Range with default outlier probability
  Humidity: { range: { min: 30, max: 60, outlierProbability: 0.05, type: 'float' } }, // Range with custom outlier probability
  Status: ["On", "Off"] // Array of values
};

const hvacColConfig = {
  "Serial Number": applianceMap["Dishwasher"], // Array of values
  TemperatureAccuracy: { range: { min: -2, max: 2, outlierProbability: 0.05, type: 'float' } }, 
  Airflow: { range: { min: 900, max: 1800, outlierProbability: 0.05, type: 'int' } },
  MaxDecibels: { range: { min: 0, max: 60, outlierProbability: 0.05, type: 'int' } },
  EnergyConsumption: { range: { min: 3, max: 4.5, outlierProbability: 0.05, type: 'float' } },
  FilterDifferential: { range: { min: 0.1, max: 0.3, outlierProbability: 0.05, type: 'float' } },
  RefrigerantLevels: { range: { min: 0, max: 1, outlierProbability: 0.05, type: 'float' } },
  DuctPressure: { range: { min: 0.3, max: 0.8, outlierProbability: 0.05, type: 'float' } }
};


generateDummyData(hvacColConfig, "hvac.json", {
  keyAttribute: "Serial Number"
});
