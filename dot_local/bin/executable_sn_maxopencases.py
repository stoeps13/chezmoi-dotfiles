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

# Find the day with the most open cases for each year
max_open_cases = []
for year in years:
    # Generate a daily date range for the year
    date_range = pd.date_range(start=f'{year}-01-01', end=f'{year}-12-31')

    # Count open cases for each day
    daily_open_cases = [
        len(df[(df['Created'] <= date) & ((df['Closed'].isna()) | (df['Closed'] > date))])
        for date in date_range
    ]

    # Find the day with the maximum open cases
    max_cases = max(daily_open_cases)
    max_date = date_range[daily_open_cases.index(max_cases)]

    max_open_cases.append({
        'Year': year,
        'Date': max_date,
        'Open Cases': max_cases
    })

# Convert max open cases data to DataFrame
max_open_cases_df = pd.DataFrame(max_open_cases)

# Plot the data
plt.figure(figsize=(10, 6))
bars = plt.bar(max_open_cases_df['Year'], max_open_cases_df['Open Cases'], color='skyblue')

# Add numbers above the bars
for bar in bars:
    height = bar.get_height()
    plt.text(
        bar.get_x() + bar.get_width() / 2, height, f'{int(height)}',
        ha='center', va='bottom', fontsize=10
    )

plt.xlabel('Year')
plt.ylabel('Maximum Open Cases')
plt.title('Most Open Cases on a Day for Each Year')
plt.xticks(years)
plt.tight_layout()

# Show the plot
plt.show()

# Optionally, save the summary to a CSV file
output_file = 'max_open_cases_summary.csv'
max_open_cases_df.to_csv(output_file, index=False)
print(f"Summary of max open cases saved to {output_file}")

