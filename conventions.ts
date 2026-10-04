import fs from "fs";
import { exit } from "process";

const blank = (s: string) => s.replace(/[^\n]/g, " ");
const stripNoise = (sql: string) =>
  sql.replace(
    /'(?:[^']|'')*'|"(?:[^"]|"")*"|(\$\w*\$)[\s\S]*?\1|--[^\n]*|\/\*[\s\S]*?\*\//g,
    (m) => {
      if (m[0] === "'") return "'" + blank(m.slice(1, -1)) + "'";
      if (m[0] === '"' || m[0] === "$") return m;
      return blank(m);
    },
  );

const data = fs.readFileSync("/dev/stdin", "utf-8");
const clearData = stripNoise(data);

interface ConvRule {
  name: string,
  description: string,
  violateRegex: RegExp,
}

const rules: ConvRule[] = [
  {
    name: "No space symbol in primary key pair",
    description: "`PRIMARY KEY (...)` -> `PRIMARY KEY(...)`",
    violateRegex: /\bPRIMARY\s+KEY\s+\(/
  },
  {
    name: "No space symbol in between check constrain and condition",
    description: "`CHECK (...)` -> `CHECK(...)`",
    violateRegex: /\bCHECK\s+\(/
  },
  {
    name: "now() instead of CURRENT_TIMESTAMP",
    description: "`CURRENT_TIMESTAMP` -> `now()",
    violateRegex: /\bCURRENT_TIMESTAMP\b/
  },
  {
    name: "now()::date instead of CURRENT_DATE",
    description: "`CURRENT_DATE` -> `now()::date`",
    violateRegex: /\bCURRENT_DATE\b/
  },
  {
    name: "Capital `now` function name",
    description: "`NOW()` -> `now()`",
    violateRegex: /\bNOW\(/
  },
  {
    name: "No space in enum creation",
    description: "`AS ENUM (...);` -> `AS ENUM(...);`",
    violateRegex: /CREATE\s+TYPE\s+[\w.]+\s+AS\s+ENUM\s+\(/i
  },

  {
    name: "No space in table creation",
    description: "`CREATE TABLE ... (...);` -> `CREATE TABLE ...(...);`",
    violateRegex: /CREATE\s+TABLE\s+(IF\s+NOT\s+EXISTS\s+)?[\w.]+\s+\(/i
  },

  {
    name: "No single-field PRIMARY KEY(...)",
    description: "`PRIMARY KEY(my_field)` -> `PRIMARY KEY(my_field, another_field)`",
    violateRegex: /PRIMARY\s+KEY\s*\(\s*\w+\s*\)/i
  },

  {
    name: "Enum names end with _enum",
    description: "`CREATE TYPE status AS ENUM(...);` -> `CREATE TYPE status_enum AS ENUM(...);`",
    violateRegex: /CREATE\s+TYPE\s+[\w.]*(?<!_enum)\s+AS\s+ENUM\b/i
  },
  {
    name: "Index names start with idx_",
    description: "`CREATE INDEX my_index ...;` -> `CREATE INDEX idx_my_index ...;`",
    violateRegex: /CREATE\s+(UNIQUE\s+)?INDEX\s+(CONCURRENTLY\s+)?(IF\s+NOT\s+EXISTS\s+)?(?!idx_|CONCURRENTLY\b|IF\b)\w+/i
  },
  {
    name: "INTEGER type",
    description: "`INTEGER` -> `INT`",
    violateRegex: /\bINTEGER\b/i
  },
  {
    name: "BOOL type",
    description: "`BOOL` -> `BOOLEAN`",
    violateRegex: /\bBOOL\b/i
  }
];

let violated = false;
for (const rule of rules) {
  if (rule.violateRegex.test(clearData)) {
    console.log(`CONV_VIOL ${rule.name}: ${rule.description}`)
    violated = true;
  }
}

if (violated) {
  exit(1);
}
