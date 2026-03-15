import pandas as pd
from sqlalchemy import create_engine

conn_string = 'postgresql://rashi:1234@localhost/painting'
engine = create_engine(conn_string)

files = ['artist','canvas_size','image_link','museum_hours','museum','product_size','subject','work']

for file in files:
    df = pd.read_csv(rf'C:\Users\user\Desktop\SQL Famous Paintings Case Study Project\{file}.csv')
    df.to_sql(file, con=engine, if_exists='replace', index=False)

print("All tables created successfully")