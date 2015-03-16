using doControlLib;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace doUIViewDesign
{
    class do_Button : doComponentUIView
    {
        public override void DrawControl(int _x, int _y, int _width, int _height, Graphics g)
        {
            base.DrawControl(_x, _y, _width, _height, g);

            string _text = this.CurrentModel.GetPropertyValue("text");
            this.drawText(g, _text,
                _x, _y, this.CurrentModel.Width, this.CurrentModel.Height, StringFormatFlags.LineLimit, true, true);
        }
    }
}
