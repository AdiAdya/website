// Test if foundUsHow column exists in production database
const { PrismaClient } = require('@prisma/client');

async function testProductionFoundUsHow() {
  console.log('🔍 Testing foundUsHow in production database...');
  
  const prisma = new PrismaClient({
    datasources: {
      db: {
        url: process.env.PRODUCTION_DATABASE_URL || process.env.DATABASE_URL
      }
    }
  });

  try {
    // Check if column exists
    console.log('📋 Checking if found_us_how column exists...');
    const result = await prisma.$queryRaw`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'users' AND column_name = 'found_us_how';
    `;
    
    console.log('Column check result:', result);
    
    if (result.length === 0) {
      console.log('❌ found_us_how column does NOT exist in production!');
      console.log('🚨 This is why CMS shows "Not specified" for all users');
      return;
    } else {
      console.log('✅ found_us_how column exists in production');
    }
      
    // Check recent users
    console.log('👥 Checking recent users...');
    const users = await prisma.user.findMany({
      select: {
        id: true,
        email: true,
        foundUsHow: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: 10,
    });
    
    console.log('Recent users with foundUsHow:');
    users.forEach(user => {
      console.log(`  📧 ${user.email}: ${user.foundUsHow || 'NULL'} (created: ${user.createdAt})`);
    });
    
    const usersWithFoundUsHow = users.filter(u => u.foundUsHow);
    console.log(`\n📊 Summary: ${usersWithFoundUsHow.length}/${users.length} users have foundUsHow data`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testProductionFoundUsHow();
