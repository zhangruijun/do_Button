using doCore.Object;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace do_Button.extdefine
{
    public abstract class button_MAbstract : doUIModule
    {
        protected button_MAbstract():base()
        {
            
        }
        /// <summary>
        /// 初始化
        /// </summary>
        public override void OnInit()
        {
            base.OnInit();
            //注册属性
        }
    }
}
