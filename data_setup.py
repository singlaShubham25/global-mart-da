import pandas as pd
import sqlalchemy as sal

# loading and cleanup
df = pd.read_csv('orders.csv', na_values=['Not Available', 'unknown'])
df.columns = df.columns.str.lower().str.replace(' ', '_')

# derive discount, sale price, profit
df['discount'] = df['list_price']*df['discount_percent']*0.01
df['sale_price'] = df['list_price'] - df['discount']
df['profit'] = df['sale_price'] - df['cost_price']

# convert data to proper data types
df['order_date'] = pd.to_datetime(df['order_date'], format='%Y-%m-%d')

# drop extra columns
df.drop(columns=['list_price', 'discount_percent', 'cost_price'], inplace=True)

# Export to database
conn_string = "mysql+mysqlconnector://root:1234@localhost/order_project"
engine = sal.create_engine(conn_string)
conn = engine.connect()
df.to_sql('orders', con=conn, index=False, if_exists='append')