import os
import wx
   
class MyCheckBox(wx.Frame):
    def __init__(self, parent, id, title):
        wx.Frame.__init__(self, parent, id, title, size=(250, 170))

        panel = wx.Panel(self, -1)
        self.cb = wx.CheckBox(panel, -1, 'Show Title', (100, 100))
        self.cb.SetValue(True)

        wx.EVT_CHECKBOX(self, self.cb.GetId(), self.ShowTitle)

        self.Show()
        self.Centre()

    def ShowTitle(self, event):
        if self.cb.GetValue():
            self.SetTitle('checkbox.py')
        else: 
            self.SetTitle('')


app = wx.App(0)
MyCheckBox(None, -1, 'checkbox.py')
app.MainLoop()
