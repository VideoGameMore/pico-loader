#pragma once

/// @brief Class for displaying a critical error message.
class ErrorDisplay
{
public:
    /// @brief Displays the given \p warningString and returns after pressing the A button.
    /// @param warningString The warning string to display.
    void PrintWarning(const char* warningString)
    {
        Print(warningString, true);
    }

    /// @brief Displays the given \p errorString and loops.
    /// @note This function does not return when \p pressAToContinue is \c false.
    /// @param errorString The error string to display.
    void PrintError(const char* errorString)
    {
        Print(errorString, false);
    }

    /// @brief Temporary test status using loader-owned VRAM heap, preserving game RAM.
    /// @return False if the temporary display buffer could not be allocated.
    bool PrintDiagnostic(const char* statusString);

private:
    void Print(const char* errorString, bool pressAToContinue, u8* diagnosticBuffer = nullptr);
};
