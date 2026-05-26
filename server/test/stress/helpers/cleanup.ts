import postgres from 'postgres';

/**
 * Clean up all stress-test records from database.
 */
export async function cleanupStressTestData(
  sql: ReturnType<typeof postgres>,
): Promise<void> {
  // 1. Delete attendances of stress test users
  await sql`
    DELETE FROM attendances 
    WHERE user_id IN (SELECT id FROM users WHERE email LIKE 'stress-%')
  `;

  // 2. Delete RSVPs of stress test users
  await sql`
    DELETE FROM rsvps 
    WHERE user_id IN (SELECT id FROM users WHERE email LIKE 'stress-%')
  `;

  // 3. Delete events created by stress test users (this cascades to sessions and their remaining attendances/rsvps)
  await sql`
    DELETE FROM events 
    WHERE created_by_id IN (SELECT id FROM users WHERE email LIKE 'stress-%')
  `;

  // 4. Finally, delete the stress test users themselves
  await sql`
    DELETE FROM users 
    WHERE email LIKE 'stress-%'
  `;
}
