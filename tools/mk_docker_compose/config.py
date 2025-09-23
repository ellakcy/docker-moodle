import subprocess
from pathlib import Path
import yaml

class MoodleConfig:
    def __init__(self):
        print("INIT")
        contents = self.__get_yaml_contents()
        config = yaml.safe_load(contents)
        for key, value in config.items():
            # Optional: convert key to valid Python identifier if needed
            setattr(self, key, value)

        self.projectBaseNames=self.__project_basenames(self.DOCKERFILES)
        
    def __project_basenames(self,dockerfiles):
        return {
            path: Path(path).parent.name  # get parent folder name
            for path in dockerfiles
        }

    def __get_yaml_contents(self):
       script_dir = Path(__file__).parent 
       # Resolve the relative path to the shell script
       sh_script = (script_dir / "../conf_to_yaml.sh").resolve()
       result = subprocess.run(
         ["bash",sh_script],
         capture_output=True,
         text=True,
         check=True
       )

       return result.stdout

