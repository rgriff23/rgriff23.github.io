"""
This code creates the 'programming proficiency' barplot on the 
'About Me' section of my website.
"""

# Import libraries
import matplotlib.pyplot as plt
import pandas as pd

# Import data
data = pd.read_csv('~/Documents/GitHub/rgriff23.github.io/assets/data/data_science_skills.csv')

# Subset to languages
languages = data[data.Skill == 'Programming languages'].iloc[::-1]

# Barplot
plt.figure(figsize=(5,5.5))
plt.barh(languages.Name, languages.Proficiency)
plt.suptitle('Programming proficiency', fontsize=20, y=1.01)
plt.title('1 = Beginner, 5 = Intermediate, 10 = Expert', fontsize=11, y=1.01)
plt.gca().spines['right'].set_color('none')
plt.gca().spines['top'].set_color('none')
plt.gca().spines['bottom'].set_color('none')
plt.gca().spines['left'].set_color('none')
plt.gca().tick_params(axis=u'both', which=u'both', length=0)