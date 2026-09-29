enum AimRigMode
{
    ONE_HANDED,
    TWO_HANDED
}

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

	static _wallhold_left = [
    {
        neck_x: 5, neck_y: 2,
        back_x: 4, back_y: 5,
        front_x: 4, front_y: 5
    }
	];
	
	static _wallhold_right = [
    {
        neck_x: 5, neck_y: 6,
        back_x: 4, back_y: 9,
        front_x: 4, front_y: 9
    }
	];

// One entry per wall-jump animation frame.
static _walljump = [
    {
        neck_x: 48, neck_y: 11,
        back_x: 42, back_y: 14,
        front_x: 41, front_y: 13
    },

    {
        neck_x: 46, neck_y: 8,
        back_x: 41, back_y: 12,
        front_x: 40, front_y: 11
    },

    {
        neck_x: 44, neck_y: 6,
        back_x: 40, back_y: 11,
        front_x: 39, front_y: 10
    },

    {
        neck_x: 43, neck_y: 3,
        back_x: 38, back_y: 9,
        front_x: 37, front_y: 8
    },

    {
        neck_x: 39, neck_y: 3,
        back_x: 36, back_y: 9,
        front_x: 35, front_y: 8
    },

    {
        neck_x: 37, neck_y: 2,
        back_x: 34, back_y: 8,
        front_x: 33, front_y: 7
    },

    {
        neck_x: 36, neck_y: 2,
        back_x: 33, back_y: 7,
        front_x: 32, front_y: 6
    },

    {
        neck_x: 33, neck_y: 1,
        back_x: 31, back_y: 8,
        front_x: 30, front_y: 7
    }
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

		case s_Player_wallHold_Left:
			_poses = _wallhold_left;
			break;
			
		case s_Player_wallHold_Right:
			_poses = _wallhold_right;
			break;
    }

    _frame = clamp(floor(_frame), 0, array_length(_poses) - 1);

    return _poses[_frame];
}