import pandas as pd
import matplotlib.pyplot as plt
import sys


if len(sys.argv) != 3:
    print("Usage: python histogram_plot tiers concurrency")
    sys.exit()

tiers = sys.argv[1].split(",")
concurrency = sys.argv[2]

for i in range(len(tiers)):
    tier = tiers[i]
    output_name = f'{tier}_wl{concurrency}.pdf'
    datasource = f'{tier}_wl{concurrency}.csv'
    data = pd.read_csv(datasource)
    request_types = list(set(data['request_type']))
    fig, axs = plt.subplots(
        len(request_types),
        1,
        figsize=(10, 6 * len(request_types)),
        tight_layout=True,
    )
    
    for j in range(len(request_types)):
        request_type = request_types[j]
        df_request_type = data[data['request_type'] == request_type]

        # Create bins and frequency table
        value_counts = df_request_type['response_time'].value_counts()
        bins, frequencies = list(value_counts.index), list(value_counts.values)

        # Plot
        axs[j].bar(bins, frequencies, width = (1)/(len(bins)**0.7), color='green', label='Frequency')
        axs[j].set_xlabel('Response time [ms]', fontsize=15)
        axs[j].set_ylabel('Frequency [#]', fontsize=15)
        axs[j].set_yscale('log')  # Apply logarithmic scale on y-axis
        axs[j].set_title(f'{tier} {request_type} Response Time Frequency', fontsize=15)
        
    plt.savefig(output_name)
