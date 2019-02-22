This script will automatically switch to a Python virtual environment after you `cd` into a Python project, then deactivate when you leave. Built on two projects by [Michael Aquilina]( https://gist.github.com/afeld/4aefc7c9493f1519e141f52b40dc6479) and [Aidan Feldman](# https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv).

## Installation

1. Install [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io).
1. Run the following command:

    If you use bash shell:

    ```bash
    chmod a+x auto_virtualenv.sh
    cp auto_virtualenv.sh ~/.auto_virtualenv
    echo "source ~/.auto_virtualenv.sh" >> ~/.bash_profile
    ```

    If you use zsh:

    ```bash
    chmod a+x auto_virtualenv.sh
    cp auto_virtualenv.sh ~/.auto_virtualenv
    echo "source ~/.auto_virtualenv.sh" >> ~/.zshrc
    ```
