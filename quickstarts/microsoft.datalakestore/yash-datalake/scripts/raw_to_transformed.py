import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import lit
import datetime

now = datetime.datetime.now()
year = str(now.year)
month = str(now.month)
day = str(now.day)
today = str(now.date())


def main(storage_account_name, container_name):
    spark = SparkSession.builder.appName("rawToTransformed").getOrCreate()

    '''
        ********************************************************************************************************
        '''
    customer_df = spark.read.csv("wasbs://"+container_name+"@"+storage_account_name+".blob.core.windows.net/datasets/customers")

    customer_df.na.drop()
    # customer_df = customer_df.withColumn("year", lit(year))
    # customer_df = customer_df.withColumn("month", lit(month))
    # customer_df = customer_df.withColumn("day", lit(day))

    customer_df.write.csv("wasbs://transformed@"+storage_account_name+".blob.core.windows.net/datasets/customers", mode='overwrite')

    '''
        ********************************************************************************************************
        '''
    demographic_df = spark.read.csv("wasbs://"+container_name+"@"+storage_account_name+".blob.core.windows.net/datasets/demographics")

    demographic_df.na.drop()
    # demographic_df = demographic_df.withColumn("year", lit(year))
    # demographic_df = demographic_df.withColumn("month", lit(month))
    # demographic_df = demographic_df.withColumn("day", lit(day))

    demographic_df.write.csv("wasbs://transformed@"+storage_account_name+".blob.core.windows.net/datasets/demographics", mode='overwrite')

    '''
        ********************************************************************************************************
        '''
    order_df = spark.read.csv("wasbs://"+container_name+"@"+storage_account_name+".blob.core.windows.net/datasets/orders")

    order_df.na.drop()
    # order_df = order_df.withColumn("year", lit(year))
    # order_df = order_df.withColumn("month", lit(month))
    # order_df = order_df.withColumn("day", lit(day))

    order_df.write.csv("wasbs://transformed@"+storage_account_name+".blob.core.windows.net/datasets/orders", mode='overwrite')
    '''
        *******************************************************************************************************
        '''
    product_df = spark.read.csv("wasbs://"+container_name+"@"+storage_account_name+".blob.core.windows.net/datasets/products")

    product_df.na.drop()
    # product_df = product_df.withColumn("year", lit(year))
    # product_df = product_df.withColumn("month", lit(month))
    # product_df = product_df.withColumn("day", lit(day))

    product_df.write.csv("wasbs://transformed@"+storage_account_name+".blob.core.windows.net/datasets/products", mode='overwrite')

    spark.stop()

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
