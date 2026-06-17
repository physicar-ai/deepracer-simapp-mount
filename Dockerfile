# ======================================================================
# DeepRacer SimApp 커스텀 이미지
# ======================================================================
# 용도: algo 컨테이너(실제 학습 수행)용 이미지
#
# 컨테이너 구조:
#   - rl_coach: SageMaker Estimator 런처 (마운트 O)
#   - algo: 실제 학습 수행 (마운트 X → 이 이미지 필요)
#   - robomaker: 평가 수행 (마운트 O)
#
# 빌드 방법:
#   cd .devcontainer/deepracer-simapp-mount
#   docker build -t physicar/deepracer-simapp:latest .
#
# 주의: markov 코드 수정 시 algo 컨테이너는 마운트되지 않으므로
#       반드시 이미지를 다시 빌드해야 변경사항이 적용됨
# ======================================================================

FROM physicar/deepracer-simapp:5.3.3-cpu

# 수정된 markov 패키지 복사
# - /opt/simapp/: SageMaker 학습 경로
# - /opt/code/ml/: 백업 경로 (일부 스크립트에서 참조)
COPY sagemaker_rl_agent/lib/python3.8/site-packages/markov/ /opt/simapp/sagemaker_rl_agent/lib/python3.8/site-packages/markov/
COPY sagemaker_rl_agent/lib/python3.8/site-packages/markov/ /opt/code/ml/sagemaker_rl_agent/lib/python3.8/site-packages/markov/
