clear 
echo "" 
numberOfModules=$(find ./Modules -name "*.zsh" -o -name "*.sh" | egrep ".sh|.zsh" | wc -l)
echo ""
echo "  Total Number of Modules: $numberOfModules "
sleep 2
echo ""
echo "  ============="
echo "  MacOS Scripts"
echo "  =============" 
find ./Modules -name "*.zsh" | sort
echo ""
echo ""
sleep 2
echo "  ============"
echo "  Unix Scripts"
echo "  ============"
find ./Modules -name "*.sh" | sort
