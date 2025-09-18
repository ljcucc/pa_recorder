# PA Recorder

PA Recorder is a Flutter-based application designed to help users create, browse, and manage psychological records (pa-records) in a structured format. It serves as a user-friendly UI version of the `generate_pa_record.py` tool, aiming to streamline the process of generating records compatible with `logseq_gen` for markdown output.

## Features

*   **Directory Selection**: Easily select your `logseq-pa` directory to manage your records.
*   **New Record Creation**: Create new pa-records following the predefined format, similar to the `generate_pa_record.py` script.
*   **Browse Records**: View and navigate through your existing pa-records.
*   **Logseq Compatibility**: Generates records in a format compatible with `logseq_gen` for seamless integration with Logseq.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install)
*   [FVM (Flutter Version Management)](https://fvm.app/docs/getting_started/installation)
*   A code editor like [VS Code](https://code.visualstudio.com/) with the Flutter extension.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/pa_recorder.git
    cd pa_recorder
    ```

2.  **Install and use the correct Flutter version with FVM:**
    ```bash
    fvm install
    fvm use
    ```

3.  **Get Flutter dependencies:**
    ```bash
    fvm flutter pub get
    ```

4.  **Run the application:**
    ```bash
    fvm flutter run
    ```

## Usage

1.  **Select logseq-pa Directory**: Upon launching the application, you will be prompted to select your `logseq-pa` directory. This directory is where your pa-records will be stored and read from.
2.  **New Record**: Click on "New Record" to start creating a new psychological record.
3.  **Browse Records**: Click on "Browse Records" to view a list of your existing pa-records.

## Contributing

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT) - see the `LICENSE` file for details.