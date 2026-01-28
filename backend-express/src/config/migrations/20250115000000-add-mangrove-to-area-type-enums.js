'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // Add 'mangrove' to diagnose_areas.area_type enum
    // PostgreSQL requires ALTER TYPE to add enum values
    // Sequelize auto-generates enum type names like: enum_diagnose_areas_area_type
    try {
      await queryInterface.sequelize.query(`
        DO $$ 
        BEGIN
          -- Try to add 'mangrove' to the enum (will fail silently if already exists in newer PostgreSQL)
          -- For older PostgreSQL versions, we check first
          IF NOT EXISTS (
            SELECT 1 FROM pg_enum e
            JOIN pg_type t ON e.enumtypid = t.oid
            WHERE t.typname = 'enum_diagnose_areas_area_type'
            AND e.enumlabel = 'mangrove'
          ) THEN
            ALTER TYPE enum_diagnose_areas_area_type ADD VALUE 'mangrove';
          END IF;
        EXCEPTION
          WHEN duplicate_object THEN
            -- Value already exists, ignore
            NULL;
        END $$;
      `);
    } catch (error) {
      // If the enum type name is different, try to find it dynamically
      const [results] = await queryInterface.sequelize.query(`
        SELECT udt_name 
        FROM information_schema.columns 
        WHERE table_name = 'diagnose_areas' 
        AND column_name = 'area_type'
        LIMIT 1;
      `);
      
      if (results && results.length > 0) {
        const enumTypeName = results[0].udt_name;
        await queryInterface.sequelize.query(`
          DO $$ 
          BEGIN
            IF NOT EXISTS (
              SELECT 1 FROM pg_enum e
              JOIN pg_type t ON e.enumtypid = t.oid
              WHERE t.typname = '${enumTypeName}'
              AND e.enumlabel = 'mangrove'
            ) THEN
              EXECUTE format('ALTER TYPE %I ADD VALUE %L', '${enumTypeName}', 'mangrove');
            END IF;
          EXCEPTION
            WHEN duplicate_object THEN
              NULL;
          END $$;
        `);
      }
    }

    // Add 'mangrove' to ml_models.area_type enum (if it exists and is an enum)
    try {
      await queryInterface.sequelize.query(`
        DO $$ 
        BEGIN
          -- Check if area_type column exists and is an enum type
          IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'ml_models' 
            AND column_name = 'area_type'
            AND udt_name LIKE 'enum_%'
          ) THEN
            -- Try to add 'mangrove' to the enum
            IF NOT EXISTS (
              SELECT 1 FROM pg_enum e
              JOIN pg_type t ON e.enumtypid = t.oid
              WHERE t.typname = 'enum_ml_models_area_type'
              AND e.enumlabel = 'mangrove'
            ) THEN
              ALTER TYPE enum_ml_models_area_type ADD VALUE 'mangrove';
            END IF;
          END IF;
        EXCEPTION
          WHEN duplicate_object THEN
            NULL;
        END $$;
      `);
    } catch (error) {
      // If the enum type name is different, try to find it dynamically
      const [results] = await queryInterface.sequelize.query(`
        SELECT udt_name 
        FROM information_schema.columns 
        WHERE table_name = 'ml_models' 
        AND column_name = 'area_type'
        AND udt_name LIKE 'enum_%'
        LIMIT 1;
      `);
      
      if (results && results.length > 0) {
        const enumTypeName = results[0].udt_name;
        await queryInterface.sequelize.query(`
          DO $$ 
          BEGIN
            IF NOT EXISTS (
              SELECT 1 FROM pg_enum e
              JOIN pg_type t ON e.enumtypid = t.oid
              WHERE t.typname = '${enumTypeName}'
              AND e.enumlabel = 'mangrove'
            ) THEN
              EXECUTE format('ALTER TYPE %I ADD VALUE %L', '${enumTypeName}', 'mangrove');
            END IF;
          EXCEPTION
            WHEN duplicate_object THEN
              NULL;
          END $$;
        `);
      }
    }
  },

  async down(queryInterface, Sequelize) {
    // Note: PostgreSQL does not support removing enum values directly
    // To rollback, you would need to:
    // 1. Create a new enum without 'mangrove'
    // 2. Alter the column to use the new enum
    // 3. Drop the old enum
    // This is complex and risky, so we'll leave it as a no-op
    // In practice, you should not rollback enum additions if there's data using them
    
    console.log('⚠️  Warning: Rolling back enum values is not supported in PostgreSQL. Manual intervention required if needed.');
  },
};
