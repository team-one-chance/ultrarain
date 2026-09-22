function player_rig_pose(_sprite, _frame)
{
    // One entry means the same attachment points are used for every frame.
    static _idle = [
        {
            neck_x: 16, neck_y: 12,
            back_x: 19, back_y: 16,
            front_x: 12, front_y: 16
        }
    ];

    static _run = [
        {
            neck_x: 33, neck_y: 5,
            back_x: 32, back_y: 7,
            front_x: 25, front_y: 7
        }
    ];

    static _air = [
        {
            neck_x: 14, neck_y: 3,
            back_x: 15, back_y: 6,
            front_x: 8, front_y: 6
        }
    ];

	
	static _slide_right = [
    {
        neck_x: 2, neck_y: 10,
        back_x: 10, back_y: 13,
        front_x: 3, front_y: 13
    }
	];
	
	static _slide_left = [
    {
        neck_x: 56, neck_y: 12,
        back_x: 45, back_y: 13,
        front_x: 52, front_y: 13
    }
	];

	static _wallholdleft = [
    {
        neck_x: 56, neck_y: 12,
        back_x: 45, back_y: 13,
        front_x: 52, front_y: 13
    }
	];

    // One entry per animation frame when the torso moves.
    static _walljump = [
        {
            neck_x: 16, neck_y: 9,
            back_x: 19, back_y: 16,
            front_x: 12, front_y: 16
        },

        {
            neck_x: 16, neck_y: 9,
            back_x: 19, back_y: 16,
            front_x: 12, front_y: 16
        }

        // Copy another {...} block for each remaining frame.
    ];
	
    var _poses = _idle;

    switch (_sprite)
    {
        case s_Player:
            _poses = _idle;
            break;

        case s_Player_Run:
            _poses = _run;
            break;

        case s_Player_Air:
            _poses = _air;
            break;

        case s_Player_wallJump:
            _poses = _walljump;
            break;
		
		case s_Player_Slide_Right:
			_poses = _slide_right;
			break;
			
		case s_Player_Slide_Left:
			_poses = _slide_left;
			break;
    }

    _frame = clamp(floor(_frame), 0, array_length(_poses) - 1);

    return _poses[_frame];
}