import glob
import csv
from datetime import datetime

# THIS CODE IS TO ASSESS HOW YOUR BINDCRAFT CONFIGS ARE PERFORMING
# Run this code in the same folder where you have your log files. It will count how many trajectories it produces and how many of them are successful. It stores them in a .csv file.

# CSV filename with date and time
timestamp = datetime.now().strftime("%d-%m-%y-%Hh%M")
csv_file = f"bindcraft_summary_{timestamp}.csv"

# Store results
csv_data = []

# Finding all the successful trajectories and successful designs in the log files and counting them
for filepath in sorted(glob.glob("*.log")):
    successes = []
    with open(filepath, 'r') as file:
        log = file.read()

    everyone = log.split('Starting trajectory: ')
    settings = log.split('Design settings used: ')[1].split('\n')[0].strip()
    target = log.split('Running binder design for target ')[1].split('\n')[0].strip()
    print(filepath)
    print(f'Design settings: {settings}')
    print(f'Target: {target}', '\n')
    print(f'Iteration count: {len(everyone)}')

    lysed = log.split('successful')
    lysed.pop()

    for i in lysed:
        attempts = i.split('Starting trajectory: ')[-1]
        success = attempts.split(' ')[0].split('Stage')[0].strip()
        total_successes = log.count('passed all filters')
        if '1PY' in success:
            successes.append(success)
    print(f'Successful trajectories: {successes}')
    print(f'Successful trajectory count: {len(successes)}')
    print(f'Total successful designs: {total_successes}')
    print('-----------------------------------')

    # Put the values above into the CSV
    csv_data.append([
        filepath,
        settings,
        target,
        len(everyone),
        ', '.join(successes),
        len(successes),
        total_successes
    ])


# Create CSV
with open(csv_file, 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)

    writer.writerow([
        'Log file',
        'Design settings',
        'Target',
        'Iteration count',
        'Successful trajectories',
        'Successful trajectory count',
        'Total successful designs'
    ])

    writer.writerows(csv_data)

print(f'\nCSV saved to: {csv_file}')


# Checking the number of trajectories in a single log file
# with open("bindcraft_2807913.log", 'r') as file:
        # log = file.read()

# lysed = log.split('Starting trajectory: ')
# print(len(lysed))
