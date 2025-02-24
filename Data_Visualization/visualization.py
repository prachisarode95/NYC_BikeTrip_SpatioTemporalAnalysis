import pandas as pd
import matplotlib.pyplot as plt

# Creating a DataFrame from the provided data
df = pd.read_csv(r'C:\Users\Administrator\Downloads\New folder\half_hour_starttime_count.csv')

df['half_hour_starttime'] = pd.to_datetime(df['half_hour_starttime'])
df.sort_values('half_hour_starttime', inplace=True)

# Plotting the histogram
plt.figure(figsize=(12, 8))
bars = plt.bar(df['half_hour_starttime'].astype(str), df['trip_count'], color='skyblue')

# Adding labels to each bar
for bar in bars:
    yval = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2, yval, int(yval), va='bottom')  # va: vertical alignment

plt.title('Bike Trips Count by Half Hour Start Times')
plt.xlabel('Half Hour Start Time')
plt.ylabel('Trip Count')
plt.xticks(rotation=45, ha="right")
plt.tight_layout()

plt.show()