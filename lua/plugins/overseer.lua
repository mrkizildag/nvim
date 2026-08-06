return {
    "stevearc/overseer.nvim",

    cmd = {
        "OverseerRun",
        "OverseerShell",
        "OverseerToggle",
        "OverseerOpen",
        "OverseerClose",
        "OverseerTaskAction",
    },

    opts = {
        strategy = {
            "terminal",
            direction = "horizontal",
            open_on_start = true,
            quit_on_exit = "never",
        },

        task_list = {
            direction = "bottom",
            min_height = 15,
            max_height = 25,
            default_detail = 1,
        },

        form = {
            border = "rounded",
        },

        task_win = {
            border = "rounded",
        },
    },
}
