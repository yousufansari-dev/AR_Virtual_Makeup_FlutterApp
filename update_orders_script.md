# Firebase Order Status Update Script

Since you have existing orders in Firebase with old statuses (pending, approved, rejected), you need to update them to the new status system. Here are two ways to do this:

## Option 1: Use the Migration Utility (Recommended)

1. Open your app as admin
2. Go to Admin Dashboard
3. Click "Migration Utility" from the drawer
4. Click "3. Migrate Order Statuses"
5. This will automatically convert:
   - `pending` → `completed`
   - `approved` → `completed` 
   - `rejected` → `cancelled`

## Option 2: Manual Firebase Console Update

If you prefer to update manually in Firebase Console:

1. Go to Firebase Console → Firestore Database
2. Navigate to the `orders` collection
3. For each order document, update the `status` field:
   - Change `pending` to `completed`
   - Change `approved` to `completed`
   - Change `rejected` to `cancelled`

## Option 3: Firestore Rules (Temporary Fix)

You can also add a temporary rule to handle old statuses by updating your Firestore security rules to automatically map old statuses:

```javascript
// In your Firestore rules, you can add logic to handle old statuses
// This is a temporary solution while you migrate
```

## Verification

After updating, verify that:
1. All orders show proper status badges (green for completed, etc.)
2. Dropdown menus work without errors
3. Users can review products from completed orders
4. No more "assertion failed" errors in admin panel

## New Status System

The new statuses are:
- `completed` - Order complete, user can review (green)
- `processing` - Order being processed (orange)  
- `shipped` - Order shipped (teal)
- `delivered` - Order delivered (blue)
- `cancelled` - Order cancelled (red)

Run the migration utility for the easiest and safest update!