import pandas as pd
import matplotlib.pyplot as plt

# Load the Excel file (adjust 'your_file.xlsx' with your actual file name)
file_path = 'sn_customerservice_case.xls'
df = pd.read_excel(file_path)


# Ensure Created and Closed columns are datetime
df['Created'] = pd.to_datetime(df['Created'])
df['Closed'] = pd.to_datetime(df['Closed'], errors='coerce')

# Generate a range of years based on Created and Closed dates
start_year = df['Created'].dt.year.min()
end_year = max(df['Created'].dt.year.max(), df['Closed'].dt.year.max())
years = list(range(start_year, end_year + 1))

# Summarize open and closed cases for each year
summary = []
for year in years:
    # Open cases as of December 31st of the year
    open_cases = df[(df['Created'] <= f'{year}-12-31') & ((df['Closed'].isna()) | (df['Closed'] > f'{year}-12-31'))]

    # Closed cases within the year
    closed_cases = df[(df['Closed'] >= f'{year}-01-01') & (df['Closed'] <= f'{year}-12-31')]

    summary.append({
        'Year': year,
        'Open': len(open_cases),
        'Closed': len(closed_cases)
    })

# Convert summary to DataFrame
summary_df = pd.DataFrame(summary)

# Plot open and closed cases
plt.figure(figsize=(10, 6))
bar_width = 0.4

bars_open = plt.bar(summary_df['Year'] - bar_width / 2, summary_df['Open'], width=bar_width, label='Open Cases', color='skyblue')
bars_closed = plt.bar(summary_df['Year'] + bar_width / 2, summary_df['Closed'], width=bar_width, label='Closed Cases', color='orange')

# Add values above the bars
for bar in bars_open:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width() / 2, height, f'{int(height)}', ha='center', va='bottom', fontsize=10)

for bar in bars_closed:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width() / 2, height, f'{int(height)}', ha='center', va='bottom', fontsize=10)

plt.xlabel('Year')
plt.ylabel('Number of Cases')
plt.title('Open and Closed Tickets per Year')
plt.xticks(years)
plt.legend()
plt.tight_layout()

# Show the plot
plt.show()

# Calculate average time to solution (Closed - Created in days)
df['Solution Time'] = (df['Closed'] - df['Created']).dt.days

# Calculate average solution time per year
avg_solution_time = df.dropna(subset=['Solution Time']).groupby(df['Closed'].dt.year)['Solution Time'].mean().reset_index()
avg_solution_time.columns = ['Year', 'Average Solution Time']

# Plot average solution time
plt.figure(figsize=(10, 6))
plt.bar(avg_solution_time['Year'], avg_solution_time['Average Solution Time'], color='green', alpha=0.7)

# Add values above the bars
for i, row in avg_solution_time.iterrows():
    plt.text(row['Year'], row['Average Solution Time'], f'{row["Average Solution Time"]:.1f}', ha='center', va='bottom', fontsize=10)

plt.xlabel('Year')
plt.ylabel('Average Solution Time (days)')
plt.title('Average Time to Solution per Year')
plt.xticks(avg_solution_time['Year'])
plt.tight_layout()

# Show the plot
plt.show()

# Optionally, save summaries to CSV files
summary_df.to_csv('open_closed_summary.csv', index=False)
print("Summary of open and closed cases saved to open_closed_summary.csv")

avg_solution_time.to_csv('avg_solution_time_summary.csv', index=False)
print("Summary of average solution times saved to avg_solution_time_summary.csv")

