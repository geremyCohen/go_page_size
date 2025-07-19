. Do not create other examples, only the ones I am defining.

. When you create files then fix them, make the fixes in the same file, do not create a "fixed" version.  I don't want a clutter-filled path structure for this project.

. Differentiate between the files I ask for, and the files you make that enable you to perform the task.  Keep the files I request in the folder I request them in, for the files you make to perform utility tasks, keep them in an "ai_util" subdirectory of FULL_PATH

. Make any .txt, .md, summary, or informational files in a "ai_readme" in the FULL_PATH subdirectory.

. Always create build artifacts to a "ai_build" folder under FULL_PATH.  You should be able to delete/clean old build folders between testing iterations easily, and I want to be able to easily add folders that contain un-needed build artifacts to a .gitignore

. For the folders and files that have temp and/or build artifacts that are not needed for committing, please add them to the root .gitignore.

. For any files that are greater than 50MB, add them to the .gitignore.

. Always test locally before telling me its done, unless I ask you to perform testing in a container.

