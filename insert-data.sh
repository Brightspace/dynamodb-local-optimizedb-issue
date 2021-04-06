export AWS_ACCESS_KEY_ID=foo
export AWS_SECRET_ACCESS_KEY=bar


ports=('8001' '8002')

for port in "${ports[@]}"
do
    for i in {1..4}
    do
        bitem=$(cat <<EOF
{ 
"val": { 
    "S": "i'm $i item" 
}, 
".pk": { 
    "B": "SXwQDl0jXk6nf/FfycsxgzlkZmNkODdmLTljYzMtNGEzOC1iMGY2LWE3ODhhNDAzZGNiZQ==" 
} 
}
EOF
)
        aws dynamodb put-item --table-name b-pk-table --item "$bitem" --endpoint-url http://localhost:$port --region=us-east-1
    done
done