-- Autogenerated lua file by the Shanker tool
-- 'Wimps and posers -- leave the hall! -- ManOwaR
--
-- DO NOT HAND EDIT.
--
dependents =
{
}
text_styles =
{
    default =
    {
        color =
        {
            0.862745098039216,
            0.862745098039216,
            0.862745098039216,
            1,
        },
        font = [[arialbd.ttf]],
        size = 14,
        dpi = 72,
        chars = [[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ><{}[].,:;!@#$%^?()&*\/-"|]],
    },
}
skins =
{
}
widgets =
{
    {
        name = [[editLabel]],
        isVisible = true,
        x = 0.2351724,
        y = 0.9386207,
        w = 0.4,
        h = 0.05,
        ctor = [[label]],
        halign = MOAITextBox.LEFT_JUSTIFY,
        valign = MOAITextBox.LEFT_JUSTIFY,
        text_style = [[default]],
        padleft = 0,
        padright = 0,
        str = [[EDIT MODE]],
    },
    {
        name = [[tooltipTxt]],
        isVisible = true,
        x = 0.2213793,
        y = 1.116552,
        w = 0.4,
        h = 0.05,
        ctor = [[label]],
        halign = MOAITextBox.LEFT_JUSTIFY,
        valign = MOAITextBox.LEFT_JUSTIFY,
        text_style = [[default]],
        padleft = 0,
        padright = 0,
        str = [[TOOLTIP]],
    },
}
properties =
{
    sinksInput = false,
}
return { dependents = dependents, text_styles = text_styles, skins = skins, widgets = widgets, properties = properties }
