#! usr/bin/bash

dir=$([ -z "$1" ] && echo "" || echo $1)
ext=$([ -z "$1" ] && echo "c" || echo $2)
count=$(ls -lR ${dir}/*.${ext} | wc -l)

# Exit if there is no file found!
if [ "$count" -eq 0 ]; then
    echo "No file found with the provided parameters!"
    exit
fi

echo "Number of files in ${dir} directory with ${ext} extention:${count}"

# Loop over the code files
for file in ${dir}/*.${ext}; do
    filename=$(basename "$file" .${ext} | tr " " _)
    mkdir -p ${dir}/${filename}
    # Create directory with filename
    clang "$file" -S -emit-llvm -o ${dir}/${filename}/${filename}.ll
    echo "Createing .dot file(s)"
    cd ${dir}/${filename}
    # Generate .dot file(s) for each function
    opt -dot-cfg ${filename}.ll -disable-output -enable-new-pm=0

    # Loop over the generated dot files
    for d_file in .*.dot; do
        p_name=$(echo "$d_file" | awk '{print substr($0, 2, length($0)-5)}')
        echo "Writing CFG for ${p_name} function"
        # Generate png from the dot files
        dot -Tpng "$d_file" > ${p_name}.png
    done
    echo "Going back to root directory..."
    cd -

done