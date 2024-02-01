import os
import subprocess


class FQEnv:
    # Instance of FQEnv class
    def __init__(
            self, 
            fqenv_root_dir = "../../",
            redpitaya_switch = True, 
            opalkelly_switch = False
        ):
        self.fqenv_root_dir = fqenv_root_dir
        self.redpitaya_switch = redpitaya_switch
        self.opalkelly_switch = opalkelly_switch
        pass


    # Run a make command
    def make(self, verbose = True, substrings = [""], make_command = "", make_command_args = ""):
        self.make_command = make_command
        self.make_command_args = make_command_args
        handle = subprocess.Popen(self.make_command+" "+make_command_args,
                         cwd=self.fqenv_root_dir,
                         stdin=subprocess.PIPE,
                         stderr=subprocess.PIPE,
                         stdout=subprocess.PIPE,
                         shell=True)

        handle.stdin.flush()

        lines = str(handle.stdout.read()).split("\\n")
        handle.stdout.flush()
        if (verbose == True):
            for line in lines:
                for substring in substrings:
                    if (line.find(substring) != -1):
                        print(line[:len(line)-2])

        lines = str(handle.stderr.read()).split("\\n")
        handle.stderr.flush()
        if (verbose == True):
            for line in lines:
                print(line[:len(line)])


    # Vivado Targets
    def reset(self, verbose = True, substrings = [""], part=""):
        make_command = "make reset"
        make_command_args = "PART="+part
        print("PY: INFO: running command ", make_command, make_command_args)
        self.make(
            verbose, substrings, make_command, make_command_args
        )


    def src(self, verbose = True, substrings = [""], top=""):
        make_command = "make src"
        make_command_args = "TOP="+top
        if (top == ""):
            print("PY: ERROR: The 'top' argument required to specify the target src file name is empty.")
        else:
            print("PY: INFO: running command ", make_command, make_command_args)
            self.make(
                verbose, substrings, make_command, make_command_args
            )


    def board(self, verbose = True, substrings = [""], board=""):
        make_command = "make board"
        make_command_args = "BOARD="+board
        if (board == ""):
            print("PY: ERROR: The 'board' argument required to specify the target board file name is empty.")
        else:
            print("PY: INFO: running command ", make_command, make_command_args)
            self.make(
                verbose, substrings, make_command, make_command_args
            )


    def generics(self, verbose = True, substrings = [""], generic_names=[], generic_vals=[]):
        # Check validity of inputted generic parameters that must match
        if len(generic_vals) == len(generic_names):
            for i in range(len(generic_vals)):
                print("PY: Generic {}: {} = {}".format(i, generic_names[i], generic_vals[i]))
        else:
            # Display error
            print("PY: ERROR: The number of inputted generic parameter names and values does not match.")
            return

        if (len(generic_names) <= 0):
            print("PY: ERROR: Generator of generic variables has been called, but no parameters were given.")
            return
        else:
            make_command = "make generics"
            list_generics = []
            for i in range(1, len(generic_names)+1):
                list_generics.append(
                    "GEN"+str(i)+"_NAME="+generic_names[i-1] +
                    " GEN"+str(i)+"_VAL="+str(generic_vals[i-1])+" ")

            make_command_args = "".join(list_generics)
            print("PY: INFO: running command ", make_command, make_command_args)
            self.make(
                verbose, substrings, make_command, make_command_args
            )


    def synth(self, verbose = True, substrings = [""]):
        make_command = "make synth"
        make_command_args = ""
        print("PY: INFO: running command ", make_command, make_command_args)
        self.make(
            verbose, substrings, make_command, make_command_args
        )


    def impl(self, verbose = True, substrings = [""]):
        make_command = "make impl"
        make_command_args = ""
        print("PY: INFO: running command ", make_command, make_command_args)
        self.make(
            verbose, substrings, make_command, make_command_args
        )


    def bit(self, verbose = True, substrings = [""]):
        make_command = "make bit"
        make_command_args = ""
        print("PY: INFO: running command ", make_command, make_command_args)
        self.make(
            verbose, substrings, make_command, make_command_args
        )


    def all(self, verbose = True, substrings = [""]):
        make_command = "make all"
        make_command_args = ""
        print("PY: INFO: running command ", make_command, make_command_args)
        self.make(
            verbose, substrings, make_command, make_command_args
        )


    def prog(self, verbose = True, substrings = [""]):
        pass


    def rp_prog(self, verbose = True, substrings = [""]):
        pass


    def sim_gui(self, verbose = True, substrings = [""]):
        pass


    def run(self, verbose = True, substrings = [""]):
        pass
        