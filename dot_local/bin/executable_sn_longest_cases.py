import pandas as pd

# Load the Excel file (adjust 'your_file.xlsx' with your actual file name)
file_path = 'sn_customerservice_case.xls'
df = pd.read_excel(file_path)

# Ensure Created and Closed columns are datetime
df['Created'] = pd.to_datetime(df['Created'])
df['Closed'] = pd.to_datetime(df['Closed'], errors='coerce')

# Calculate time to resolution in days
df['Solution Time'] = (df['Closed'] - df['Created']).dt.days

# Drop cases without a resolution time (e.g., still open or missing dates)
df = df.dropna(subset=['Solution Time'])

# Sort by Solution Time in descending order
longest_running_cases = df.nlargest(10, 'Solution Time')[['Number', 'Subject', 'Solution Time', 'Closed']]

# Output the results to the console
print("Top 10 Longest Running Cases:")
print(longest_running_cases.to_string(index=False))
