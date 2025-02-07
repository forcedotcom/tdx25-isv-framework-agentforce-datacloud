const fs = require("fs");
const path = require("path");
const readline = require("readline");

// Create an interface for reading input from the command line
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const fileName = "renamespaceOutput.txt";

// Function to prompt the user for input
const prompt = (query) => new Promise((resolve) => rl.question(query, resolve));

// Function to recursively search and replace in files
const searchAndReplaceContents = async (
  dir,
  searchTerm,
  replaceTerm,
  dryRun,
  output
) => {
  const files = fs.readdirSync(dir);

  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat.isDirectory()) {
      // Skip .sfdx, .sf, and .git directories
      if (file === ".sfdx" || file === ".git" || file === ".sf") {
        continue;
      }
      await searchAndReplaceContents(
        filePath,
        searchTerm,
        replaceTerm,
        dryRun,
        output
      );
    } else {
      const content = fs.readFileSync(filePath, "utf8");
      if (content.includes(searchTerm)) {
        if (dryRun) {
          output.push(`[Dry Run] Would replace in file: ${filePath}`);
        } else {
          const result = content.replace(
            new RegExp(searchTerm, "g"),
            replaceTerm
          );
          fs.writeFileSync(filePath, result, "utf8", (err) => {
            if (err) throw err;
            output.push(`Replaced in file: ${filePath}`);
          });
        }
      }
    }
  }
};

// Function to search and replace terms in filenames
const searchAndReplaceFilenames = async (
  dir,
  searchTerm,
  replaceTerm,
  dryRun,
  output
) => {
  const files = fs.readdirSync(dir);

  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);

    if (stat.isDirectory()) {
      await searchAndReplaceFilenames(
        filePath,
        searchTerm,
        replaceTerm,
        dryRun,
        output
      );
    } else {
      const newFileName = file.split(searchTerm).join(replaceTerm);
      const newFilePath = path.join(dir, newFileName);

      if (newFileName !== file) {
        if (dryRun) {
          output.push(
            `[Dry Run] Would rename file: ${filePath} to ${newFilePath}`
          );
        } else {
          fs.renameSync(filePath, newFilePath);
          output.push(`Renamed file: ${filePath} to ${newFilePath}`);
        }
      }
    }
  }
};

// write contents of output to file
const writeOutput = (fileName, output) => {
  fs.writeFileSync(fileName, output.join("\n"), "utf8");
};

// Main function to execute the script
const main = async () => {
  const output = [];
  const searchTerm = await prompt("Enter the term to search for: ");
  const replaceTerm = await prompt("Enter the term to replace with: ");
  const dryRunInput = await prompt("Run in dry run mode? (yes/no): ");
  const dryRun = dryRunInput.toLowerCase() !== "no";
  console.log("");
  console.log(`${dryRun ? "DRY RUN" : "Updating files..."}`);
  output.push(`${dryRun ? "DRY RUN" : ""} Renamespace Output ${Date()}`);

  const baseDir = path.join(__dirname, "../../");
  await Promise.all([
    searchAndReplaceContents(baseDir, searchTerm, replaceTerm, dryRun, output),
    searchAndReplaceFilenames(baseDir, searchTerm, replaceTerm, dryRun, output)
  ]);
  writeOutput(fileName, output);
  console.log(`Complete - File listing written to ${fileName}`);
  rl.close();
};

main();
