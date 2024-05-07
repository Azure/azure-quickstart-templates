# imports
import os
import mlflow
import argparse

import pandas as pd
import lightgbm as lgbm
import matplotlib.pyplot as plt

from sklearn.metrics import log_loss, accuracy_score
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

# define functions
def main(args):
    # enable auto logging
    mlflow.autolog()

    # setup parameters
    num_boost_round = args.num_boost_round
    params = {
        "objective": "multiclass",
        "num_class": 3,
        "boosting": args.boosting,
        "num_iterations": args.num_iterations,
        "num_leaves": args.num_leaves,
        "num_threads": args.num_threads,
        "learning_rate": args.learning_rate,
        "metric": args.metric,
        "seed": args.seed,
        "verbose": args.verbose,
    }

    # read in data
    df = pd.read_csv(args.iris_csv)

    # process data
    X_train, X_test, y_train, y_test, enc = process_data(df)

    # train model
    model = train_model(params, num_boost_round, X_train, X_test, y_train, y_test)


def process_data(df):
    # split dataframe into X and y
    X = df.drop(["species"], axis=1)
    y = df["species"]

    # encode label
    enc = LabelEncoder()
    y = enc.fit_transform(y)

    # train/test split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # return splits and encoder
    return X_train, X_test, y_train, y_test, enc


def train_model(params, num_boost_round, X_train, X_test, y_train, y_test):
    # create lightgbm datasets
    train_data = lgbm.Dataset(X_train, label=y_train)
    test_data = lgbm.Dataset(X_test, label=y_test)

    # train model
    model = lgbm.train(
        params,
        train_data,
        num_boost_round=num_boost_round,
        valid_sets=[test_data],
        valid_names=["test"],
    )

    # return model
    return model


def parse_args():
    # setup arg parser
    parser = argparse.ArgumentParser()

    # add arguments
    parser.add_argument("--iris-csv", type=str)
    parser.add_argument("--num-boost-round", type=int, default=10)
    parser.add_argument("--boosting", type=str, default="gbdt")
    parser.add_argument("--num-iterations", type=int, default=16)
    parser.add_argument("--num-leaves", type=int, default=31)
    parser.add_argument("--num-threads", type=int, default=0)
    parser.add_argument("--learning-rate", type=float, default=0.1)
    parser.add_argument("--metric", type=str, default="multi_logloss")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--verbose", type=int, default=0)

    # parse args
    args = parser.parse_args()

    # return args
    return args


# run script
if __name__ == "__main__":
    # parse args
    args = parse_args()

    # run main function
    main(args)