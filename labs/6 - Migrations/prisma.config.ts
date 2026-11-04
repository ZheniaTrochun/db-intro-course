import { defineConfig } from '@prisma/config';
import { config } from './config';

export default defineConfig({
    schema: 'prisma/schema',
    migrations: {
      path: 'prisma/migrations'
    },
    datasource: {
        url: config.DB_URL,
    },
});
