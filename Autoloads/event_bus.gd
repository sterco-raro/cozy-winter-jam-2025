extends Node

#region GLOBALS
var action_in_progress: bool = false
#endregion

#region DATA SIGNALS
signal task_start(id: int)
signal task_end(id: int)
#endregion
