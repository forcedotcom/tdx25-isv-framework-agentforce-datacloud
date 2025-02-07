const fs = require("fs");
const { v4: uuidv4 } = require("uuid"); // For UUID generation
const { format } = require("date-fns"); // For date formatting (install: npm install date-fns)
const path = require("path");

const institutionNames = [
  "Keuka Science and Math",
  "Seneca Academy",
  "Cayuga Preperatory",
  "Canandaigua Day School"
];
function generateCSV(filename, numIndividuals) {
  const groups = [
    "lacrosse",
    "hockey",
    "volleyball",
    "soccer",
    "field hockey",
    "debate team",
    "community service",
    "political science",
    "biology",
    "economics"
  ];

  const csvData = [];
  csvData.push("Id,first name,last name,email,amount,group,createdDate"); // Header row

  for (let i = 0; i < numIndividuals; i++) {
    const firstName = `FirstName${i}`;
    const lastName = `LastName${i}`;
    const email = `${firstName}.${lastName}@${["example.com", "test.net", "domain.org"][Math.floor(Math.random() * 3)]}`;

    const numRowsPerIndividual = Math.floor(Math.random() * 5) + 1; // 1 to 5 rows per individual

    for (let j = 0; j < numRowsPerIndividual; j++) {
      const id = uuidv4(); // UUID unique per ROW
      const amount = parseFloat((Math.random() * 990 + 10).toFixed(2));
      const group = groups[Math.floor(Math.random() * groups.length)];
      const createdDate = format(
        new Date(
          Date.now() - Math.floor(Math.random() * 365 * 24 * 60 * 60 * 1000)
        ),
        "yyyy-MM-dd HH:mm:ss"
      );

      csvData.push(
        `${id},${firstName},${lastName},${email},${amount.toFixed(2)},${group},${createdDate}`
      );
    }
  }

  const dataDir = path.resolve(__dirname, "../../data");
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir);
  }

  const filePath = path.join(dataDir, filename);
  fs.writeFileSync(filePath, csvData.join("\n"));
  console.log(`${filePath} generated successfully!`);
}

// loop institutions and kabob case the name - include the current date time stamp in the file name

institutionNames.forEach((name) => {
  const filename = `${name.replace(/\s/g, "-")}_${format(new Date(), "yyyyMMdd_HHmmss")}.csv`;
  generateCSV(filename, 100);
});
