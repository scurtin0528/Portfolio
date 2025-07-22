# -*- coding: utf-8 -*-
#to start streamlit, you need to type this into command prompt. 
#cd C:\Users\Scott\.spyder-py3
#streamlit run C:\Users\Scott\.spyder-py3\streamlit_ex.py
# i am interested in a particular demographic, how does their spending differ from others? what do they spend
# most on ? least on? how does that compare to others? savings rates. 
"""
Created on Wed Oct 23 10:38:34 2024

@author: Scott
"""

import time # for simulating a real-time data, time loop          
import numpy as np # np mean, np random             
import pandas as pd # read csv, df manipulation                 
import plotly.express as px # interactive charts              
import streamlit as st # data web application development
import requests, zipfile, io
import matplotlib.pyplot as plt


st.set_page_config(
    page_title="Real-Time Data Dashboard",
    page_icon="🔄",  # This sets an emoji as the icon
    layout="wide",
)

series_df = pd.read_csv("C:/Python/series.txt", sep='\t', dtype={'item_code': str, 'series_id': str})

series_df.columns = ['series_id', 'seasonal', 'category_code', 'subcategory_code','item_code','demographics_code','characteristics_code','process_code','series_title','footnote_code','begin_year','begin_period','end_year','end_period']

lab_df = pd.read_csv("C:/Python/Alldata.txt", sep='\t')

lab_df.columns = ['series_id', 'year', 'period', 'value','footnote_codes']

dem_df = pd.read_csv("C:/Python/demographics.txt", sep='\t')

dem_df.columns = ['demographics_code', 'demographics_text', 'display_level', 'selectable','sort_sequence']

dem_df = dem_df[['demographics_code', 'demographics_text']]

char_df = pd.read_csv("C:/Python/characteristics.txt", sep='\t')

char_df.columns = ['demographics_code', 'characteristics_code', 'characteristics_text','display_level','selectable','sort_sequence']

char_df = char_df[['demographics_code', 'characteristics_code', 'characteristics_text']]



item_df = pd.read_csv("C:/Python/item.txt", sep='\t')

item_df.columns = ['subcategory_code','item_code','item_text','display_level','selectable','sort_sequence']

item_df = item_df[['subcategory_code', 'item_code', 'item_text','display_level']]

item_df = item_df.sort_values(by='display_level')

subcat_df = pd.read_csv("C:/Python/subcat.txt", sep='\t')

subcat_df.columns = ['category_code','subcategory_code','subcategory_text','display_level','selectable','sort_sequence']

subcat_df = subcat_df[['subcategory_code','subcategory_text']]

subcat_df = subcat_df.sort_values(by='subcategory_text')
#agg_item = item_df[item_df['display_level'] == 0]
#agg_item2 = item_df[item_df['display_level'] > 0]


series_df['series_id'].str.len().head(10)
lab_df['series_id'].str.len().head(10)
#Removing leading/trailing blanks

#lab_df['series_id'] = lab_df['series_id'].str.strip()
#series_df['series_id2'] = lab_df['series_id'].str.strip()

lab_filter = lab_df[lab_df["series_id"] == 'CXU001010LB2009M              ']
series_filter = series_df[series_df["series_id"] == 'CXUWOMENSLB2109M              ']

df_series = pd.merge(lab_df, series_df, on=['series_id'], how='inner')
df_series_dem = pd.merge(df_series, dem_df, on=['demographics_code'], how='inner')
df_series_dem_char = pd.merge(df_series_dem, char_df, on=['demographics_code','characteristics_code'], how='inner')
df_series_dem_char_item = pd.merge(df_series_dem_char, item_df, on=['subcategory_code','item_code'], how='inner')
df_series_dem_char_subitem_item = pd.merge(df_series_dem_char_item, subcat_df, on=['subcategory_code'], how='inner')

#next step is crate a dataset with all 0 level display items from which a user cna pick which to map on trend
#line for all demographic groups. 
#add_char = pd.merge(lab_df, char_df, on=['characteristics_code','demographics_code'], how='left')

Lookup = df_series_dem_char_subitem_item[df_series_dem_char_subitem_item["series_id"] == 'CXU980071LB0101M              ']

dem_filter = st.selectbox(
    "Select the demographic", 
    pd.unique(dem_df["demographics_text"])
)

subcat_filter = st.selectbox(
    "Select a category", 
    pd.unique(subcat_df["subcategory_text"])
)

# Dynamically filter 'display_level' based on selected demographic and subcategory
filtered_display_levels = df_series_dem_char_subitem_item.loc[
    (df_series_dem_char_subitem_item["demographics_text"] == dem_filter) &
    (df_series_dem_char_subitem_item["subcategory_text"] == subcat_filter),
    "display_level"
]

sorted_display_levels = sorted(filtered_display_levels.unique())

# Ensure we only show unique levels
display_filter = st.selectbox(
    "Select a level of detail", 
    pd.unique(sorted_display_levels)
)

# Step 3: Dynamically filter item options based on previous selections
filtered_items = df_series_dem_char_subitem_item.loc[
    (df_series_dem_char_subitem_item["demographics_text"] == dem_filter) &
    (df_series_dem_char_subitem_item["subcategory_text"] == subcat_filter) &
    (df_series_dem_char_subitem_item["display_level"] == display_filter),
    "item_text"
]

# Step 4: Item filter
item_filter = st.selectbox(
    "Select a more detailed item (if needed)",
    pd.unique(filtered_items)
)

# Filter the DataFrame for visualization or further processing
filtered_df = df_series_dem_char_subitem_item.loc[
    (df_series_dem_char_subitem_item["demographics_text"] == dem_filter) &
    (df_series_dem_char_subitem_item["subcategory_text"] == subcat_filter) &
    (df_series_dem_char_subitem_item["item_text"] == item_filter)
]

# Display the filtered DataFrame for testing
st.write(filtered_df)

#dem_filter

#df_series_dem_char_item = df_series_dem_char_item[
#    (df_series_dem_char_item["demographics_text"] == series_filter) & (df_series_dem_char_item["year"] == year_filter)
#]

fig_col1 = st.columns(1)

with fig_col1[0]:
    st.markdown("### Chart 1")

    # Create the line chart, using the 'characteristics_text' column to differentiate lines
    fig1 = px.line(data_frame=filtered_df, 
                   x="year", 
                   y="value", 
                   color="characteristics_text",  # Use the 'characteristics_text' column to differentiate lines
                   title= item_filter + " by " + dem_filter)

    # Format the layout to increase chart size and move legend further down
    fig1.update_layout(
        width=1000,   # Set the width of the chart
        height=600,   # Set the height of the chart
        xaxis_title="Year",
        xaxis_title_font=dict(
            family="Arial",
            size=14,
            color="blue"
        ),
        xaxis=dict(
            tickmode='array',
            tickvals=filtered_df['year'],
            ticktext=[str(year) for year in filtered_df['year']],
            tickangle=45,
            tickfont=dict(
                size=12,
                family="Arial",
                color="green"
            )
        ),
        legend=dict(
            title="Characteristics",
            title_font=dict(
                family="Arial",
                size=14,
                color="black"
            ),
            font=dict(
                family="Arial",
                size=12,
                color="black"
            ),
            orientation="h",
            x=0.5,
            xanchor="center",
            y=-0.5,  # Move legend further down
            yanchor="bottom"
        )
    )

    # Display the chart using st.plotly_chart with container width off for custom size
    st.plotly_chart(fig1, use_container_width=False)

# Extract unique years and sort them
years_df = lab_df["year"]
sorted_years = sorted(years_df.unique())

# Create a selectbox for year selection
year_filter = st.selectbox(
    "Select a year", 
    sorted_years  # Pass the sorted list of years directly
)

cat_filter = st.selectbox(
    "Select a category", 
    pd.unique(char_df["characteristics_text"])
)

# Filter the dataframe based on the selected demographic and year
year_filtered_df = df_series_dem_char_subitem_item.loc[
    (df_series_dem_char_subitem_item['demographics_text'] == dem_filter) &
    (df_series_dem_char_subitem_item['year'] == year_filter) &
    (df_series_dem_char_subitem_item['category_code'] == 'EXPEND') &
    (df_series_dem_char_subitem_item['characteristics_text'] == cat_filter) &
    (df_series_dem_char_subitem_item['item_code'] != 'TOTALEXP')
]


# Determine the largest expenditures
largest_expenditures = year_filtered_df.sort_values(by='value', ascending=False).head(10)
largest_expenditures = largest_expenditures.sort_values(by='value', ascending=True)
# Display results
st.write("Largest Expenditures for Selected Demographic and Year:")
st.dataframe(largest_expenditures)

# Create a single column for layout
fig_col2 = st.columns(1)

# Access the column (even though there's only one)
with fig_col2[0]:
    if not largest_expenditures.empty:
        largest_expenditures = largest_expenditures.iloc[::-1]
        # Create the Plotly Express bar chart
        fig = px.bar(
            largest_expenditures,
            x='value',  # Expenditure value
            y='item_text',  # Item name
            orientation='h',  # Horizontal bars
            color='item_text',  # Color by item_text to show item names in the legend
            labels={'value': 'Expenditure', 'item_text': 'Item'},
            title='Top Expenditures for Selected Demographic and Year'
        )

        # Update the legend title to reflect the item_text values
        fig.update_layout(
            legend_title=dict(text='Expenditure Items'),  # Custom legend title
            legend=dict(
                title_font=dict(size=14),
                font=dict(size=12)
            )
        )

        # Display the chart in Streamlit
        st.plotly_chart(fig)
    else:
        # Inform the user if no data is available
        st.write("No data available for the selected filters.")



                            