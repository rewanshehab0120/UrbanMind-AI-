# Distance Models

This folder contains separate Jupyter notebooks for the two distance-based
regression models:

- SVM_Model.ipynb: Support Vector Regression.
- KNN_Model.ipynb: K-Nearest Neighbours Regression.

Each notebook starts by running the project preprocessing notebook. The
preprocessing workflow supplies cleaned, engineered, selected, and scaled
training and testing datasets. The model notebook then trains one model,
reports MAE, RMSE, and R2, and shows actual-versus-predicted and residual
plots.

Run either notebook from this folder. The preprocessing notebook now locates
the source CSV automatically when it is launched from a model folder.
