# addinR

A collection of useful RStudio addins to enhance your R development workflow with file management, directory navigation, and text manipulation utilities.

## Installation

Install directly from GitHub using the `devtools` package:

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install addinR
devtools::install_github("Yousuf28/addinR")
```

After installation, restart RStudio to access the addins through the **Addins** menu.

- ![Addin Menu]('.github/menu.png')

- ![Available Addins]('.github/addin.png')

## What This Package Does

The `addinR` package provides a suite of RStudio addins designed to streamline common development tasks that would otherwise require manual file operations or repetitive typing. These addins integrate seamlessly into your RStudio workflow, accessible through keyboard shortcuts or the Addins menu.

## How It Helps RStudio Users

### **Text Manipulation**
- **Replace Backslash with Forwardslash**: Instantly convert Windows-style paths (`\`) to Unix-style paths (`/`) in selected text
- **Replace Forwardslash with Backslash**: Convert Unix-style paths to Windows-style paths for cross-platform compatibility

### **File and Directory Operations**
- **Open Working Directory in File Explorer**: Quickly access your current working directory in your system's file manager (Windows Explorer, Finder, or Linux file manager)
- **Copy Current File Contents**: Copy the entire contents of your active R file to the clipboard for easy sharing or backup
- **Copy All R Files**: Batch copy all R files content from your working directory to clipboard, perfect for sharing project code or creating documentation
- **Copy Selected R Files**: Interactively choose which R files content to copy from your working directory

### **Terminal Integration**
- **Open Git Bash Here**: Launch Git Bash terminal directly in your current working directory (Windows)
- **Open Alacritty Here**: Open Alacritty terminal in your current directory (cross-platform)

### **Session Directory Management**
- **Remember Current Directory**: Save frequently used directories during your R session
- **Return to Remembered Directory**: Quickly navigate back to previously saved directories and automatically update the Files pane

## Key Benefits

1. **Eliminates Repetitive Tasks**: No more manually typing file paths or navigating through multiple folders
2. **Cross-Platform Compatibility**: Works on Windows, macOS, and Linux
3. **Seamless Integration**: All functions are accessible through RStudio's Addins menu and can be assigned keyboard shortcuts
4. **Productivity Boost**: Reduces context switching between RStudio and external applications
5. **Code Sharing Made Easy**: Quickly copy and share R code files with colleagues or for documentation
6. **Enhanced Terminal Workflow**: Direct terminal access from your current working context

## Usage

After installation, access these tools through:
- **Addins menu** in RStudio's toolbar
- **Assign keyboard shortcuts** via Tools → Modify Keyboard Shortcuts
- **Command palette** (Ctrl/Cmd + Shift + P)

These addins are particularly valuable for:
- Data scientists working with multiple file paths
- Package developers managing complex project structures
- Analysts sharing code across different operating systems
- Anyone who frequently switches between RStudio and terminal/file explorer

Transform your RStudio experience with these time-saving utilities that handle the mundane tasks so you can focus on your analysis and development work.
