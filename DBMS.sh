#!/bin/bash
function EntryPage() {
  clear
  echo -e "\e[36m"
  echo "  ██████╗ ██████╗ ███╗   ███╗    ███╗   ███╗███████╗███████╗"
  echo " ██╔════╝██╔═══██╗████╗ ████║    ████╗ ████║██╔════╝██╔════╝"
  echo " ██║     ██║   ██║██╔████╔██║    ██╔████╔██║█████╗  █████╗  "
  echo " ██║     ██║   ██║██║╚██╔╝██║    ██║╚██╔╝██║██╔══╝  ██╔══╝  "
  echo " ╚██████╗╚██████╔╝██║ ╚═╝ ██║    ██║ ╚═╝ ██║███████╗███████╗"
  echo "  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝    ╚═╝     ╚═╝╚══════╝╚══════╝"
  echo -e "\e[0m"
  echo -e "\n📦 Welcome to Bash DBMS — manage your databases with ease!\n"
  echo -e "\e[32mPress any key to continue...\e[0m"
  read -n 1
  MainMenu
}
function MainMenu(){ 
  source ./DB_manager.sh
  clear
  echo -e "\e[36m\n==== 🌟 Main Menu 🌟 ===="
  PS3=$'\e[35mPlease choose an option: \e[0m'
  menu=("📁 Create Database" "📋 List Databases" "🔌 Connect To Databases" "🗑️  Drop Database" "🚪 Exit the DBMS")
  select option in "${menu[@]}"; do
    case $REPLY in
      1) CreateDB; break;;
      2) ListDBs; break;;
      3) ConnectDB; break;;
      4) DropDB; break;;
      5) echo -e "\n👋 Exiting... Bye!"; exit 0;;
      *) echo -e "\e[33m⚠️  $REPLY isn't in the list. Please choose a valid option.\e[0m";;
    esac
  done
}

function connect_menu() {
  clear
  echo -e "\n\e[35m🔗 Connected to your database successfully!\e[0m"
  echo -e "\e[36m📂 Choose an action:\e[0m"
  echo "-----------------------------------------"

  PS3=$'\n\e[33m📌 Enter your choice: \e[0m'
  menu=(
    "🆕 Create Table"
    "📃 List Tables"
    "🗑️ Drop Tables"
    "➕ Insert into Table"
    "🔍 Select From Table"
    "❌ Delete From Table"
    "✏️ Update Table"
    "🏠 Back to Main Menu"
    "🚪 Exit"
  )

  select option in "${menu[@]}"; do
    case $REPLY in
      1) Create_Table ; break ;;
      2) List_Tables ; break ;;
      3) Drop_Tables ; break ;;
      4) Insert ; break ;;
      5)
        echo -e "\n\e[36m🔎 Select Type:\e[0m"
        select var in "📋 Select All" "📌 Select by Column" "🧮 Projection"; do
          case $REPLY in
            1) Slect_all ; break ;;
            2) Slect_equal ; break ;;
            3) generate_the_projection ; break ;;
            *) echo -e "\e[31m❌ Invalid selection.\e[0m" ;;
          esac
        done
        break
        ;;
      6) DeletFromTable ; break ;;
      7) Update ; break ;;
      8) MainMenu ; break ;;
      9) exit 0 ;;
      *) echo -e "\e[31m❌ $REPLY is not a valid choice. Try again.\e[0m" ;;
    esac
  done
}

EntryPage
