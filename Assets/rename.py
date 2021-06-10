# Pythono3 code to rename multiple 
# files in a directory or folder
  
# importing os module
import os
  
# Function to rename multiple files
def main():
  
    folder = input()
    for count, filename in enumerate(os.listdir(folder)):
        dst = "card" + str(count) + ".png"
        src = folder + filename
        dst = folder + dst
          
        # rename() function will
        # rename all the files
        os.rename(src, dst)
  
# Driver Code
if __name__ == '__main__':
      
    # Calling main() function
    main()