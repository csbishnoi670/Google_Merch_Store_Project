import pandas as pd

# 1. Force string types on load to prevent float truncation of GA4 IDs
dtypes = {'user_id': str, 'session_id': str, 'event_id': str, 'transaction_id': str}

dim_users = pd.read_csv('dim_users.csv', dtype=dtypes)
dim_sessions = pd.read_csv('dim_sessions.csv', dtype=dtypes)
fct_events = pd.read_csv('fct_events.csv', dtype=dtypes)

# 2. Check for Orphaned Events (Events without a valid Session)
orphaned_events = fct_events[~fct_events['session_id'].isin(dim_sessions['session_id'])]
orphan_rate = (len(orphaned_events) / len(fct_events)) * 100

print(f"Total Orphaned Events: {len(orphaned_events)}")
print(f"Orphan Rate: {orphan_rate:.4f}%")

# 3. Quick structural check on the IDs
print("\nSample Session IDs (Ensure no scientific notation/truncation):")
print(fct_events['session_id'].head(3).tolist())