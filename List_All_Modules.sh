clear 
echo "" 
numberOfModules=$(find ./Modules -name "*.zsh" -o -name "*.sh" | egrep ".sh|.zsh" | wc -l)
echo "  Total Number of Modules: $numberOfModules "
numberOfMacModules=$(find ./Modules -name "*.zsh" | egrep ".zsh" | wc -l)
numberOfUnixModules=$(find ./Modules -name "*.sh" | egrep ".sh" | wc -l)
sleep 2
echo ""
echo "  MacOS Scripts $numberOfMacModules "
echo "  ========================" 
find ./Modules -name "*.zsh" | sort
echo ""
echo ""
sleep 3
echo "  Unix Scripts $numberOfUnixModules "
echo "  ======================="
find ./Modules -name "*.sh" | sort
