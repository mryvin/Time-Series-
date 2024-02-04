<h1>Consumer Price Index Forecasting with Moving Block Bootstrap 🌡🔮📈</h1>
<p>This project applies a moving block bootstrap method to monthly Consumer Price Index (CPI) prices of different countries grouped by development, region, and income. The project uses the <a href="https://www.kaggle.com/datasets/theworldbank/global-economic-monitor">Global Economic Monitor</a> dataset from Kaggle, which provides daily updates of global economic developments. The project aims to test the hypothesis that the average change in prices has increased in high, middle, and developing countries from 1989 to 2019. 🌎</p>

<h2>Project Workflow 📝</h2>
<h3>1. Data Cleaning </h3>
<p>The original dataset had some issues that needed to be fixed before analysis. The low income country column was removed because of missing and negative values. The last month was also removed because of missing values. Three subsets were created for different time periods: 1989-2019, 2012-2019, and 2017-2019. 🧹</p>
<h3>2. Data Analysis </h3>
<p>The cleaned data was analyzed using a moving block bootstrap method. The time series data was Box-Cox transformed and decomposed into trend, seasonal, and random variation components. The random variation components were bootstrapped from contiguous sections of the time series and joined together. The trend and seasonal components were combined with the bootstrap variation components, and the Box-Cox transform was inverted. The original data, the bootstrap simulations, and the forecast were plotted for each column of the dataset. The average and standard deviation of the predicted values were also printed for each column. 📊</p>
<h2>Tools & Technologies Used 🛠</h2>
<ul>
  <li>R </li>
  <li>readxl </li>
  <li>dplyr </li>
  <li>tidyr </li>
  <li>fpp2 </li>
</ul>
<h2>Project Conclusion 🏁</h2>
<p>The project reached the following conclusions based on the first subset of data (1989-2019) to the second subset (2012-2019):</p>
<ul>
  <li>The Average CPI for High Income Countries did not match the hypothesis - decrease in the average change in prices</li>
  <li>The Average CPI for Middle Income Countries did match the hypothesis - increase in the average change in prices</li>
  <li>The Average CPI for Developing Countries did not match the hypothesis - decrease in the average change in prices</li>
</ul>

