import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, BaggingClassifier, VotingClassifier
from sklearn.linear_model import SGDClassifier
from sklearn.svm import NuSVC
from sklearn.naive_bayes import GaussianNB
from sklearn.model_selection import StratifiedKFold, cross_val_score, train_test_split
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.ensemble import StackingClassifier

# Load datasets
cobia = pd.read_csv('cobia.csv')
oyster = pd.read_csv('oyster.csv')

def prepare_data(df):
    X = df.iloc[:, :-1]  # Select all columns except the last as features
    y = df.iloc[:, -1]   # Select the last column as the target label
    y = y + 1  # Shift labels: {-1, 0, 1} → {0, 1, 2}
    return X, y

# Prepare datasets
X_cobia, y_cobia = prepare_data(cobia)
X_oyster, y_oyster = prepare_data(oyster)

# Combine datasets
X = np.vstack((X_cobia, X_oyster))
y = np.concatenate((y_cobia, y_oyster))

# Standardize features
scaler = StandardScaler()
X = scaler.fit_transform(X)

# Define Stratified K-Fold cross-validation
kfold = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

# Define Nested Ensemble Model
base_learners = [
    ('svc', make_pipeline(StandardScaler(), NuSVC(probability=True))),
    ('sgd', make_pipeline(StandardScaler(), SGDClassifier(loss='log_loss'))),
    ('rf', RandomForestClassifier(n_estimators=100, random_state=42))
]
meta_learner = RandomForestClassifier(n_estimators=50, random_state=42)
stacking = StackingClassifier(estimators=base_learners, final_estimator=meta_learner, passthrough=True)

bagging = BaggingClassifier(base_estimator=stacking, n_estimators=10, random_state=42)

voting = VotingClassifier(estimators=[
    ('bagging', bagging),
    ('smo', make_pipeline(StandardScaler(), NuSVC(probability=True))),
    ('nb', GaussianNB())
], voting='soft')

# Perform cross-validation
cv_scores = cross_val_score(voting, X, y, cv=kfold, scoring='accuracy')

# Print results
print(f'Cross-Validation Accuracy Scores: {cv_scores}')
print(f'Average CV Accuracy: {cv_scores.mean():.4f}')

# Train model on full dataset
voting.fit(X, y)

# Make predictions and shift back labels (0,1,2 → -1,0,1)
y_pred = voting.predict(X) - 1

# Print adjusted predictions
print(f'Adjusted Predictions: {y_pred[:10]}')
