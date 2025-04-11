#!/bin/bash 
export Project="$PWD/DB_project"
function BackToTheMainMenu(){ 
    MainMenu
}
function check_the_name (){
  name="$*"
  if [[ $name =~ ^[A-Z][0-9A-Za-z_-]+$ ]]; then
  return 0
  else 
  echo -e "\e[31m❌ Please enter a valid name.\e[0m"
  return 1
  fi
}
function CheckType(){
  local input=$1
  local field=$2
  echo "${field[*]}" | awk -v list="${input[*]}" 'BEGIN {split(list, a, " "); count=0} { 
      for(i in a){
      flag=0
      for(j=1;j<=NF;j++){
      if(a[i]==$j){ flag=1; break }
      }
      if (flag==0)
      count++
      }
      if(count!=0)
      print "1"

  }'
}
function CreateDB(){
  
   [[ ! -d $Project ]] && mkdir -p "$Project"
  read -p $'\e[36m📦 Please enter the database name: \e[0m' DB_name
  if check_the_name "$DB_name";then
  if [[ -d "$Project/$DB_name" ]];then
  echo -e "\e[33m🚫 Database already exists! 🔁 Please try again with a new name.\e[0m"
  CreateDB
  else
  mkdir -p "$Project/$DB_name"
  # echo "$(check_the_name "$DB_name")"s
  echo -e "\e[32m✅ $DB_name has been successfully created! 🎉\e[0m"
  sleep 1
  MainMenu
  fi
  else
  CreateDB
  fi
  
  }
function ListDBs() {
  echo -e "\n\e[34m📂 List of Available Databases:\e[0m"
  local i=1
  for DB in $(ls -F "$Project" | grep '/'); do
    echo -e "\e[32m$i) 📁 ${DB%/}\e[0m"
    ((i++))
  done

  echo -e "\n\e[36m🏠 Press <M> to return to the Main Menu\n"

  while true; do
   read -p $'\e[36m👉 Enter your choice: \e[0m' option
    case "$option" in
      M) MainMenu ;;
      *)
        echo -e "\e[33m⚠️  Invalid choice. Please try again. \e[0m"
        ;;
    esac
  done
}
function ConnectDB(){
  while true ;do
  read -p $'\e[36m🔌 Enter the DB you want to connect to: \e[0m' DB
  if check_the_name "$DB";then
  if [[ -d "$Project/$DB" ]];then
  echo -e "\e[36m🔗 Connecting to $DB... 🚀\e[0m"
  . cd "$Project/$DB"
  break
  else
  echo -e "\e[31m❌ The database doesn't exist! 🔍 Please try again.\e[0m"
  continue
  fi
  else
  continue
  fi
  done
  connect_menu
}

function DropDB() {
  read -p $'\e[36m🗑️  Enter the name of the database you want to delete: \e[0m' DB

  if check_the_name "$DB"; then
    if [[ -d "$Project/$DB" ]]; then
      rm -r "$Project/$DB"
      echo -e "\e[32m✅ $DB has been successfully deleted! 🧹\e[0m"
      
    else
      echo -e "\e[31m❌ The database '$DB' does not exist. Please try again. 🔍\e[0m"
      DropDB
    fi
  else
    echo -e "\e[33m⚠️  Invalid database name. Please try again.\e[0m"
    DropDB
  fi
  echo -e "\n\e[36m🏠 Press <M> to return to the Main Menu\n🗑️  Press <D> to delete another database\e[0m\n"
  while true; do
   read -p $'\e[36m👉 Enter your choice: \e[0m' option
    case "$option" in
      M) MainMenu ;;
      D) DropDB ;;
      *)
        echo -e "\e[33m⚠️  Invalid choice. Please try again. \e[0m"
        ;;
    esac
  done
}

function Drop_Tables() {
  read -p $'\e[36m🗑️ Please enter the name of the table to delete: \e[0m' name
  echo ""

  if [[ -f "$name" ]]; then
    echo -e "\e[33m💣 Deleting the table $name... \e[0m"
    > "$name"
    echo -e "\e[32m✅ Table $name has been successfully deleted! 🧹\e[0m"
  else
    echo -e "\e[31m❌ Table $name doesn't exist. Please try again. 🔍\e[0m"
    Drop_Tables
    return
  fi

  echo -e "\n\e[36m🏠  Press \e[33m<M>\e[36m to return to the \e[32mMain Menu\e[36m"
  echo -e "⬅️  Press \e[33m<P>\e[36m to go to the \e[35mPrevious Menu\e[36m"
  echo -e "🗑️  Press \e[33m<D>\e[36m to delete \e[31manother table\e[0m\n"

  while true; do
    read -p $'\e[36m👉 Enter your choice: \e[0m' option
    case "$option" in
      M) MainMenu ;;  # Go to the main menu
      P) connect_menu ;;  # Go to the previous menu
      D) Drop_Tables ;;  # Delete another table
      *)
        echo -e "\e[33m⚠️ Invalid choice. Please try again.\e[0m"
        ;;
    esac
  done
}

function List_Tables() {
  local i=1
  local tables=($(ls . | grep -v '\.MetaData$'))  # Capture files as an array
  
  echo -e "\e[36m📋 List of Tables:\e[0m"
  
  for table in "${tables[@]}"; do
    echo -e "\e[32m$i) $table\e[0m"
    i=$((i + 1))
  done 
  
  while true; do
    echo -e "\n\e[36m🏠 Press \e[33m<M>\e[36m to return to the \e[32mMain Menu\e[36m"
    echo -e "⬅️ Press \e[33m<P>\e[36m to go to the \e[35mPrevious Menu\e[36m\n"

    read -p $'\e[36mEnter your choice: \e[0m' r
    case "$r" in
      M) MainMenu ;;  # Go to the main menu
      P) connect_menu ;;  # Go to the previous menu
      *)
        echo -e "\e[33m⚠️ Invalid option. Please try again.\e[0m"
        continue
        ;;
    esac
    break
  done
  
}

function Insert() {
  declare -a data
  
  # Get table name
  if [[ -n "$1" && -f "$1" ]]; then
    read -r name < "$1"
  else   
    CheckTable
  fi

  # Get number of fields from metadata
  num=$(awk -F: '{ print NF; exit }' "$name.MetaData")
  
  for ((i=1; i <= num; i++)); do
    field_with_type=$(cut -d ':' -f$i "$name.MetaData" | tr '\n' ' ')
    IFS=' ' read -r field type <<< $field_with_type
    
    while true; do
      # Handle primary key input
      if [[ $i -eq 1 ]]; then 
        read -p $'\e[36m🔑 Enter the primary key \e[32m'"$field"$'\e[36m: \e[0m' field2
      else
        read -p $'\e[36m📑 Enter the \e[32m'"$field"$'\e[36m: \e[0m' field2
      fi

      # Validation for string and integer types
      if [[ $type == "string" && ! $field2 =~ ^-?[0-9]+$ && ! $field2 =~ ^$ ]]; then
        if [[ $i -eq 1 ]]; then
          if cut -d ':' -f1 "$name" | grep -q "$field2"; then
            echo -e "\e[31m❌ Error: This primary key must be unique.\e[0m"
            i=$((i-1))
            continue 2
          else
            data+=($field2)
          fi
        else
          data+=($field2)
        fi
        break
      elif [[ $type == "int" && $field2 =~ ^-?[0-9]+$ ]]; then
        if [[ $i -eq 1 ]]; then
          if cut -d ':' -f1 "$name" | grep -q "$field2"; then
            echo -e "\e[31m❌ Error: This primary key must be unique.\e[0m"
            i=$((i-1))
            continue 2
          else
            data+=($field2)
          fi
        else
          data+=($field2)
        fi
        break
      else
        echo -e "\e[31m❌ Type error: Invalid input format.\e[0m"
      fi
    done
  done

  # Append data to table
  unset IFS
  IFS=':'
  echo "${data[*]}" >> "$name"

  # Option to insert another record or return to menu
  while true; do
    echo -e "\n\e[36m📝 Record successfully inserted! ✅\e[0m"
    echo -e "\n\e[36m🏠 Press <M> to return to the Main Menu\n⬅️ Press <P> to go to the Previous Menu\n🆕 Press <I> to insert another record\e[0m"
    read -p $'\e[36mEnter your choice: \e[0m' r

    case $r in
      M) MainMenu ;;
      P) connect_menu ;;
      I) Insert ;;
      *) echo -e "\e[33m⚠️ Invalid choice. Please try again.\e[0m" ;;
    esac

    case "$r" in
      M) MainMenu ;;  # Go to the main menu
      P) connect_menu ;;  # Go to the previous menu
      I) Insert ;;  # Insert another record
      *)
        echo -e "\e[33m⚠️ Invalid option. Please try again.\e[0m"
        continue
        ;;
    esac
    break
  done
}

function checkString(){
 local Value=$1
 local Type=$2
    if [[ $Type == "string" && ! $Value =~ ^-?[0-9]+$ && ! $Value =~ ^$ ]] ;then
    echo true
    else
    echo false
    fi

}
function checkIntger(){
  local Type=$2
  local Value=$1

  if [[ $Type == "int" &&  $Value =~ ^-?[0-9]+$ ]];then
      echo true
      else
      echo false
      fi
}
function checkPK() {
  choice=$1
  value=$2
  local name=$3
  if [[ $choice -eq 1 ]]; then
    awk -F : -v value="$value" '
      BEGIN { flag = "true" }
      {
        if ($1 == value) {
          print "1"
          flag = "false"
        }
      }
      END {
        if (flag == "true") print "0"
        
      }
    ' "$name"
    else echo "0"

  fi
}
function Update(){ 
      while true;do
        read -p $'\e[36m📋 Please enter the table name: \e[0m' name
        if [[ -f "$name" ]];then
      IFS=':' read -ra fields <<< "$(head -n 1 "$name.MetaData")"
      PS3=$'\e[36m🔍 Search by: \e[0m'

      while true; do
      echo -e "\n\e[34mPlease choose a field to search by:\e[0m"
      select var in "${fields[@]}"; do
        if [[ -n "$var" ]]; then
          field_num=$REPLY
          the_field=$var
          break
        else
          echo -e "\e[31m❌ \e[1m$REPLY isn't in the list, please enter a valid choice.\e[0m"
        fi
      done
      break  # Add this if you only want to run the loop once
      done

      # unset PS3
      type1=$(cut -d ':'  -f $field_num "$name.MetaData" | awk '{if(NR==2) print }')
    cut -d ':'  -f $field_num "$name.MetaData" | awk '{if(NR==1)print "the field is :",$0 ; else print "its type:",$0}'
      
      while true;do
      read -p $'\e[36m✏️  Enter the record you want to update: \e[0m' search
        if [[ $(checkString $search $type1) == true ]];then
        flag=$(awk -F : -v Vsearch=$search -v numSearch=$field_num  ' BEGIN{flag="true"} {if($numSearch==Vsearch) flag="false" } END {if(flag=="true") print "false" } ' "$name")
      if [[ $flag == "false" ]];then
      echo -e "\e[33m🔍 \e[1mRecord not found. Please try again.\e[0m"
      continue
      else
        PS3=$'\e[36m🔄 Select the field you want to update: \e[0m'
      while true; do
      select var in "${fields[@]}"; do
        if [[ -n "$var" ]]; then
          field_num2=$REPLY
          the_field2=$var
          echo -e "\e[32m✔️ You selected: $the_field2\e[0m"
          break 3
        else
          echo -e "\e[31m❌ \e[1m$REPLY isn't in the list, please enter a valid choice.\e[0m"
        fi
      done
      done

      fi
      elif [[ $(checkIntger $search $type1 ) == true ]];then
      flag=$(awk -F : -v Vsearch=$search -v numSearch=$field_num  ' BEGIN{flag="true"} {if($numSearch==Vsearch) flag="false" } END {if(flag=="true") print "false" } ' "$name")
      if [[ $flag == "false" ]];then
        echo -e "\e[33m🔍 \e[1mRecord not found. Please try again.\e[0m"
        continue
      else 
        PS3=$'\e[36m🔄 Select the field you want to update: \e[0m'
      while true; do
      select var in "${fields[@]}"; do
        if [[ -n "$var" ]]; then
          field_num2=$REPLY
          the_field2=$var
          echo -e "\e[32m✔️ You selected: $the_field2\e[0m"
          break 3
        else
          echo -e "\e[31m❌ \e[1m$REPLY isn't in the list, please enter a valid choice.\e[0m"
        fi
      done
      done
        fi
        else 
          echo -e "\e[31m❌ \e[1mType error: Invalid input format.\e[0m"
        fi
        done



      type2=$(cut -d ':'  -f $field_num2 "$name.MetaData" | awk '{if(NR==2) print }')

      #cut -d ':'  -f $field_num2 "$name.MetaData" | awk '{if(NR==1)print "the field is :",$0 ; else print "its type:",$0}'


      while true;do
      read -p $'\e[36m📥 Please enter the update value: \e[0m' value
      if [[ $(checkString $value $type2) == true ]];then
      while true;do
      # echo "$(checkPK $field_num2 $value $name )"
      if [[ "$(checkPK $field_num2 $value $name )" == "0" ]];then
      awk -F : -v num_update=$field_num2 -v VUpdate=$value -v Vsearch=$search -v numSearch=$field_num 'BEGIN {OFS=":"} {if($numSearch == Vsearch) $num_update = VUpdate; print}' "$name" > "$name.tmp" && mv "$name.tmp" "$name"
      break
      else
      echo -e "\e[31m❌ \e[1mError:\e[0m \e[31mThis value already exists as a primary key in the database. Enter a unique value ..\e[0m"
      continue 2
      fi
      done
      echo -e "\e[32m✅ \e[1mRecord updated successfully.\e[0m"
      echo "---------------------------------"
      echo -e "\n\e[36m🔄 To update another record, press <U>\n🏠 To return to the main menu, press <M>\n⬅️ To go to the previous menu, press <P>\e[0m"

      while true; do
      read -p $'\e[36m👉 Enter your choice: \e[0m' option
        # Handle valid options
        if [[ $option == "U" ]]; then
          continue 3  # Skip to next iteration
        elif [[ $option == "M" ]]; then
          MainMenu  # Go to the main menu
        elif [[ $option == "P" ]]; then
          connect_menu  # Go to the previous menu
        else
          # If none of the valid options were entered
          echo -e "\e[33m⚠️  Invalid choice. Please try again. \e[0m"
          continue  # Keep looping without breaking
        fi
      done


      break
        elif [[ $(checkIntger $value $type2 ) == true ]];then
        while true;do
      # echo "$(checkPK $field_num2 $value $name )"
      if [[ "$(checkPK $field_num2 $value $name )" == "0" ]];then
      awk -F : -v num_update=$field_num2 -v VUpdate=$value -v Vsearch=$search -v numSearch=$field_num 'BEGIN {OFS=":"} {if($numSearch == Vsearch) $num_update = VUpdate; print}' "$name" > "$name.tmp" && mv "$name.tmp" "$name"

      break
      else
      echo -e "\e[31m❌ \e[1mError:\e[0m \e[31mThis value already exists as a primary key in the database. Enter a unique value ..\e[0m"
      continue 2
      fi
      done
      echo -e "\e[32m✅ \e[1mRecord updated successfully.\e[0m"
      echo "---------------------------------"
      echo -e "\n\e[36m🔄 To update another record, press <U>\n🏠 To return to the main menu, press <M>\n⬅️ To go to the previous menu, press <P>\e[0m"

      while true; do
      read -p $'\e[36m👉 Enter your choice: \e[0m' option
        # Handle valid options
        if [[ $option == "U" ]]; then
          continue 3  # Skip to next iteration
        elif [[ $option == "M" ]]; then
          MainMenu  # Go to the main menu
        elif [[ $option == "P" ]]; then
          connect_menu  # Go to the previous menu
        else
          # If none of the valid options were entered
          echo -e "\e[33m⚠️  Invalid choice. Please try again. \e[0m"
          continue  # Keep looping without breaking
        fi
      done

        break
        else 
        echo -e "\e[31m❌ \e[1mType error: Invalid input format.\e[0m"
        fi
        done
        else
        echo -e "\e[31m❌  The table isn't existed! \e[0m"
        fi
        done
}
function Create_Table() {
  declare -a fields=()
  declare -a types=()

  read -p $'\e[36m📋 Please enter the table name: \e[0m' table_name
  if check_the_name "$table_name";then 
  if [[ ! -f "$table_name" ]];then
    echo -e "\e[33m🛠️  Creating the table...\e[0m"
    touch "$table_name"
    touch "$table_name.MetaData"
    
    read -p $'\e[36m🔢 Please enter the number of fields (1-20): \e[0m' number_of_fields
    
    # Validate number of fields
    while [[ ! $number_of_fields =~ ^[0-9]+$ || $number_of_fields -gt 20 || "$number_of_fields" -lt 1 ]]; do
      echo -e "\e[31m❌ Error: Invalid input. Please enter a valid number between 1 and 20.\e[0m"
      read -p $'\e[36m🔢 Please enter the number of fields (1-20): \e[0m' number_of_fields
    done

    # Collect field names and types
    for ((i = 0; i < $number_of_fields; i++)); do
      IFS=' ' read -p $'\e[36m📋 Enter field name and type (string or int): \e[0m' field_name field_type
      
      while ! check_the_name "$field_name"; do
        echo -e "\e[31m❌ Error: Invalid field name. Please try again.\e[0m"
        read -p $'\e[36m📋 Please enter the field name again: \e[0m' field_name
      done

      while [[ $field_type != "string" && $field_type != "int" ]]; do
        echo -e "\e[31m❌ Error: Please enter a valid field type (string or int).\e[0m"
        read -p $'\e[36m📋 Please enter the field type again: \e[0m' field_type
      done

      fields+=("$field_name")
      types+=("$field_type")
    done
  else 
  echo -e "\e[31m❌ Error: The table already exists.\e[0m"
  Create_Table
  fi
  else
  Create_Table
  fi


  # Write to metadata file
  IFS=':'
  echo "${fields[*]}" >> "$table_name.MetaData"
  echo "${types[*]}" >> "$table_name.MetaData"
  echo -e "\e[32m✅ The table '$table_name' has been successfully created! 🏆\e[0m"

  unset IFS

  # Menu options
  while true; do
    echo -e "\n\e[36m🏠 Press <M> to return to the Main Menu\n⬅️ Press <P> to go to the Previous Menu\n🆕 Press <C> to create another table\e[0m"
    read -p $'\e[36mEnter your choice: \e[0m' r
    case "$r" in
      M) MainMenu ;;  # Go to the main menu
      P) connect_menu ;;  # Go to the previous menu
      C) Create_Table ;;  # Create another table
      *)
        echo -e "\e[33m⚠️ Invalid option. Please try again.\e[0m"
        continue
        ;;
    esac
    break
  done
}

function generate_the_projection(){
  CheckTable
  IFS=':' read -ra fields <<< $(head -n 1 "$name.MetaData")
  while true;do
  IFS=':' read -p $'\e[36mPlease enter the columns you want to view [column1:column2]: \e[0m' -ra input
  declare -i check=$(CheckType  "${input[*]}" "${fields[*]}")
  if [[ $check -eq 1 ]];then
  echo -e "\e[31m❌ Invalid input, please try again. \e[0m"
  else
  read -ra field_nums <<< "$(echo "${fields[*]}" | awk -v list="${input[*]}" 'BEGIN {split(list, a, " ")} { for(i=1;i<=NF;i++){
      for(j in a){
      if(a[j] == $i)
      print i
      }
      }
      } ' | tr '\n ' ' ')"
      break
      fi
      done
      #  echo ${input[@]}
    awk -F : -v list="${field_nums[*]}" -v list2="${input[*]}" 'BEGIN {split(list,a," ");split(list2,b," ");for(j in b) {printf "%-16s%s",b[j],"|"} print "\n--------------------------------------------------------" } {for(i in a) {printf "%-16s%s",$a[i],"|"} printf "\n" }' "$name"
          SelectBack  
  }

function Slect_equal(){
  CheckTable
  IFS=':' read -ra fields <<< "$(head -n 1 "$name.MetaData")"

  while true ;do
    select var in "${fields[@]}"; do
      if [[ -n "$var" ]]; then
        field_num=$REPLY
        break
      else
        echo -e "\e[33m⚠️  $REPLY isn't in the list. Please enter a valid choice.\e[0m"
      fi
    done
    type=$(cut -d ':'  -f $field_num "$name.MetaData" | awk '{if(NR==2) print }')
  while true;do
    read -p $'\e[36m🔍 Please enter the value you want to match: \e[0m' match
     if [[ $(checkString $match $type) == true ]];then
    awk -F : -v match1="$match" -v fieldNum="$field_num" -v list="${fields[*]}" '
      BEGIN {
        split(list, a, " ");
        for (j in a) {
          printf "%-16s%s", a[j], "|"
        }
        print "\n--------------------------------------------------------"
        found = 0
      }
      {
        if ($fieldNum == match1) {
          found = 1
          for (i = 1; i <= NF; i++) {
            printf "%-16s%s", $i, "|"
          }
          printf "\n"
        }
      }
      END {
        if (found == 0) {
          print "❌ No matching records found."
        }
      }' "$name"
  break 2
  elif [[ $(checkIntger $match $type ) == true ]];then
   awk -F : -v match1="$match" -v fieldNum="$field_num" -v list="${fields[*]}" '
      BEGIN {
        split(list, a, " ");
        for (j in a) {
          printf "%-16s%s", a[j], "|"
        }
        print "\n--------------------------------------------------------"
        found = 0
      }
      {
        if ($fieldNum == match1) {
          found = 1
          for (i = 1; i <= NF; i++) {
            printf "%-16s%s", $i, "|"
          }
          printf "\n"
        }
      }
      END {
        if (found == 0) {
          print "❌ No matching records found."
        }
      }' "$name"
  break 2
  else 
   echo -e "\e[31m❌ \e[1mType error: Invalid input format.\e[0m"
   continue
  fi
  done

  done
  SelectBack

}

function Slect_all(){
    CheckTable
    IFS=':' read -ra fields <<< $(head -n 1 "$name.MetaData")
    awk -F : -v list="${fields[*]}" 'BEGIN {split(list,a," ");for(j in a) {printf "%-16s%s",a[j],"|"} print "\n--------------------------------------------------------" } 
    {for(i=1;i<=NF;i++) {printf "%-16s%s",$i,"|"} printf "\n" }' "$name"
    SelectBack
    
}

function DeletFromTable() {

  while true ;do
      read -p $'\e[36m📋 Please enter the table name: \e[0m' name
      if [[ -f "$name" ]];then
    IFS=':' read -ra fields <<< "$(head -n 1 "$name.MetaData")"
    PS3="search by: "
    while true; do
      select var in "${fields[@]}"; do
        if [[ -n "$var" ]]; then
          field_num=$REPLY
          the_field=$var
          break
        else
          echo -e "\e[31m❌ \e[1m$REPLY isn't in the list, please enter a valid choice.\e[0m"
        fi
      done
      break  # Add this if you only want to run the loop once
    done
    unset PS3
    type1=$(cut -d ':'  -f $field_num "$name.MetaData" | awk '{if(NR==2) print }')
  # 
  cut -d ':'  -f $field_num "$name.MetaData" | awk '{if(NR==1)print "the field is :",$0 ; else print "its type:",$0}'
    
    while true;do
    read -p "please enter the  record you want to delete : " search
  if [[ $(checkString $search $type1) == true ]];then
  flag=$(awk -F : -v Vsearch=$search -v numSearch=$field_num  ' BEGIN{flag="true"} {if($numSearch==Vsearch) flag="false" } END {if(flag=="true") print "false" } ' "$name")
  if [[ $flag == "false" ]];then
  echo -e "\e[33m🔍 \e[1mRecord not found. Please try again.\e[0m"
  continue
  else
  awk -F : -v Vsearch=$search -v numSearch=$field_num '{if($numSearch!=Vsearch) print}' "$name" > "$name.tmp" && mv "$name.tmp" "$name"
  echo -e "\e[32m✅ \e[1mRecord deleted successfully.\e[0m"
  echo " ---------------------------------------------------"
  echo -e "🗑️  To delete another record, press <D>\n🏠  To return to the main menu, press <M>\n⬅️  To go to the previous menu, press <P>"
  while true;do
 read -p $'\e[36m👉 Enter your choice: \e[0m' option
    # Handle valid options
    if [[ $option == "D" ]]; then
      continue 2  # Skip to next iteration
    elif [[ $option == "M" ]]; then
      MainMenu  # Go to the main menu
    elif [[ $option == "P" ]]; then
      connect_menu  # Go to the previous menu
    else
      # If none of the valid options were entered
      echo -e "\e[33m⚠️  Invalid choice. Please try again. \e[0m"

      continue  # Keep looping without breaking
    fi
  done
  fi
  elif [[ $(checkIntger $search $type1 ) == true ]];then
  flag=$(awk -F : -v Vsearch=$search -v numSearch=$field_num  ' BEGIN{flag="true"} {if($numSearch==Vsearch) flag="false" } END {if(flag=="true") print "false"} ' "$name")
  if [[ $flag == "false" ]];then
  echo "🔍 Record not found. Please try again."
  continue
  else
  awk -F : -v Vsearch=$search -v numSearch=$field_num '{if($numSearch!=Vsearch) print }' "$name" > "$name.tmp" && mv "$name.tmp" "$name"
  echo -e "\e[32m✅ \e[1mRecord deleted successfully.\e[0m"
  echo " ---------------------------------------------------"
  echo -e "🗑️  To delete another record, press <D>\n🏠  To return to the main menu, press <M>\n⬅️  To go to the previous menu, press <P>"
  while true;do
 read -p $'\e[36m👉 Enter your choice: \e[0m' option
    # Handle valid options
    if [[ $option == "D" ]]; then
      continue 2  # Skip to next iteration
    elif [[ $option == "M" ]]; then
      MainMenu  # Go to the main menu
    elif [[ $option == "P" ]]; then
      connect_menu  # Go to the previous menu
    else
      # If none of the valid options were entered
      echo -e "\e[33m⚠️  Invalid choice. Please try again. \e[0m"
      continue  # Keep looping without breaking
    fi
  done
  break
  fi
  else
  echo -e "\e[31m❌ \e[1mType error: Invalid input format.\e[0m"
  fi
  done
  break
  else
  echo -e "\e[31m❌  The table isn't existed! please try again \e[0m"
  fi
  done
}
function CheckTable() {
  read -p $'\e[36m📋 Please enter the table name: \e[0m' name
  
  # Check if the table file exists
  if [[ -f "$name" ]]; then
    echo -e "\e[32m✅ The table '$name' exists.\e[0m"
  else
    echo -e "\e[31m❌ Error: The table '$name' does not exist.\e[0m"
    CheckTable
  fi
}
function SelectBack(){
  echo -e "\n🏠 Press <M> to return to the Main Menu"
  echo -e "🔙 Press <P> to return to the Previous Menu"
  echo -e "🔁 Press <S> to Select Again\n"

  while true; do
   read -p $'\e[36m👉 Enter your choice: \e[0m' option
    case "$option" in
      M) MainMenu ;;
      P) connect_menu ;;       # Replace 'go_back' with your actual previous menu function
      S) "${FUNCNAME[1]}" ;;   # Replace 'Slect_equal' with your actual select function
      *)
        echo -e "\e[33m⚠️  Invalid choice. Please try again. \e[0m"
        ;;
    esac
  done

}


