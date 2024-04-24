PROTO_OUT_DIR=../Proto

packages=(
  analysis
  auth
  billing
  messenger
  users
)

for package in "${packages[@]}"; do
  protoc \
    --proto_path="${JONO_PATH}"/proto \
    --swift_opt=FileNaming=DropPath \
    --swift_out=${PROTO_OUT_DIR} \
    "${JONO_PATH}"/proto/"${package}"/*.proto;
done
