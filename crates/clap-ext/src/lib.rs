//! clap-ext: shared Rust CLI extension library.
//!
//! Public API:
//! - [`prelude`]: common imports
//! - [`common_args`]: shared arg structs (ConfigArg, Verbosity, OutputFormat)
//! - [`common_subcommands`]: shared subcommands (Init, Validate, Version)
//! - [`error`]: `CliError` enum with thiserror + anyhow integration
//! - [`logging`]: tracing-subscriber setup
//! - [`clap_based_cli`]: [`crate::clap_based_cli::CliPort`] trait +
//!   [`crate::clap_based_cli::ClapBasedCli`] adapter (clap implementation)

pub mod clap_based_cli;
pub mod common_args;
pub mod common_subcommands;
pub mod error;
pub mod logging;

pub mod prelude {
    //! Common imports for adopting crates.

    pub use crate::clap_based_cli::{
        ClapBasedCli, CliPort, GlobalOptions, ParsedCli, ParsedInvocation,
    };
    pub use crate::common_args::{ConfigArg, OutputFormat, Verbosity};
    pub use crate::common_subcommands::{InitCmd, ValidateCmd, VersionCmd};
    pub use crate::error::{CliError, CliResult};
    pub use crate::logging::setup_tracing;
}
