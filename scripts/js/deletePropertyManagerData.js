const { execSync } = require("child_process");
const path = require("path");
const { writeToPath } = require("@fast-csv/format");

const objectList = ["Case", "Contact", "Appliance__c", "Unit__c" ];

for (let object in objectList) {
  let objectResult = execSync(
    'sf data query -q "SELECT Id from ' + objectList[object] + '" --json',
    { encoding: "utf8" }
  );
  let parsedObjectResult = JSON.parse(objectResult).result.records;
  console.log(
    `> ${parsedObjectResult.length} ${objectList[object]} records fetched`
  );

  const objectRows = [];
  parsedObjectResult.forEach((record) => {
    objectRows.push({
      Id: record.Id,
    });
  });

  const filename = `${objectList[object]}_RecordsToDelete.csv`;

  writeToPath(path.resolve(__dirname, `../../data/${filename}`), objectRows, {
    headers: true,
  })
    .on("error", (err) => console.error(err))
    .on("finish", () => {
      execSync(
        `sf data delete bulk -f data/${filename} -w 5 -s ${objectList[object]}`,
        { encoding: "utf8" }
      );
      console.log(`Done deleting ${objectList[object]}.`);
    });
}
