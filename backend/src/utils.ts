import dotenv from "dotenv";
import fs from "fs";
import { readdir } from "node:fs/promises";
import { Logger } from "./logger";
import pg from "pg";
import { Response } from "express";

const log = new Logger();

dotenv.config({ path: __dirname + "/../.env" });

const { Pool } = pg;

const pool = new Pool({
  user: process.env.PGUSER,
  host: process.env.PGHOST,
  database: process.env.PGDATABASE,
  password: process.env.PGPASSWORD,
  port: parseInt(process.env.PGPORT!),
});

export async function updateDatabase(ip: string, country: string): Promise<void> {
  const { rows } = await pool.query(`SELECT * FROM users WHERE ip=$1`, [ip]);

  if (rows[0]) {
    const timesPreviouslyUsed = rows[0].times_used;
    const timeOrTimes = timesPreviouslyUsed > 1 ? "times" : "time";

    log.info(`This user has used the downloader ${timesPreviouslyUsed} ${timeOrTimes} before.`);

    pool.query(
      `UPDATE users SET times_used = $1, last_used = $2 WHERE ip = $3;`,
      [timesPreviouslyUsed + 1, new Date().toLocaleString(), ip],
      (err: Error | null) => {
        if (err) log.error(`[Postgres UPDATE] ${err.stack}`);
      }
    );
  } else {
    pool.query(
      `INSERT INTO users(ip, country, times_used) VALUES ($1, $2, 1);`,
      [ip, country],
      (err: Error | null) => {
        if (err) log.error(`[Postgres INSERT] ${err.stack}`);
      }
    );
  }
}

export function sendFile(res: Response, filename: string): void {
  res.download(filename, (err: Error | undefined) => {
    if (err) {
      log.error(`Unable to send ${filename} to the browser:\n${err}`);
    }
  });
}

export async function deleteFile(filepath: string): Promise<void> {
  try {
    await fs.promises.unlink(filepath);
  } catch (err: unknown) {
    if (err instanceof Error) {
      log.error(`Unable to delete ${filepath}:\n${err.message}`);
    }
  }
}

const substrings: string[] = [
  ".mp4.part",
  ".m4a.part",
  ".webm.part",
  ".f137.mp4",
  ".f140.m4a",
  ".f401.mp4",
  ".temp.mp4",
  ".mp4.ytdl",
];

export async function purgeUnwantedFiles(): Promise<void> {
  try {
    const files = await readdir(__dirname + "/../");

    for (const file of files) {
      if (substrings.some((substring) => file.endsWith(substring))) {
        await deleteFile(__dirname + "/../" + file);
      }
    }
  } catch (error: unknown) {
    if (error instanceof Error) {
      log.error(`purgeUnwantedFiles:\n${error.message}`);
    }
  }
}
