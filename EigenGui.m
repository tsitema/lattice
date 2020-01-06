function varargout = EigenGui(varargin)
% EIGENGUI MATLAB code for EigenGui.fig
%      EIGENGUI, by itself, creates a new EIGENGUI or raises the existing
%      singleton*.
%
%      H = EIGENGUI returns the handle to a new EIGENGUI or the handle to
%      the existing singleton*.
%
%      EIGENGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EIGENGUI.M with the given input arguments.
%
%      EIGENGUI('Property','Value',...) creates a new EIGENGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EigenGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EigenGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EigenGui

% Last Modified by GUIDE v2.5 06-Jan-2020 16:51:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EigenGui_OpeningFcn, ...
                   'gui_OutputFcn',  @EigenGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EigenGui is made visible.
function EigenGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EigenGui (see VARARGIN)
include;
data.seig=1;
data.egs=0;
data.lattice=0;
set(handles.figure1,'UserData',data);%selected eigenvalue
replot_eig(handles);
%replot_mode(handles);
% Choose default command line output for EigenGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EigenGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function Eigenval_plot_callback(hObject, eventdata, handles) 
%get stored data
data=get(handles.figure1,'UserData');
%find hitpoint
points=eventdata.IntersectionPoint;
hitpnt=abs(real(data.egs.values)-points(1))+abs(imag(data.egs.values)-points(2));
[~,index]=min(hitpnt);
data.seig=index;
replot_mode(handles);
%store data
set(handles.figure1,'UserData',data);
disp(index)

function replot_eig(handles)
%read parameters from sliders
pump=get(handles.pump_slider,'value');
M=get(handles.M_slider,'value');
loss=get(handles.loss_slider,'value');;
alpha=get(handles.alpha_slider,'value');
%get stored data
data=get(handles.figure1,'UserData');
%calculate eigensystem
[data.egs,data.lattice]=calculate(pump,M,loss,alpha);
%rewrite user data
set(handles.figure1,'UserData',data);
%plot eigenvalue spectrum
set(handles.figure1,'CurrentAxes',handles.Eigenval_plot);
scatter(real(data.egs.values), imag(data.egs.values), 'r');
% %highlight selected data
% hold on
% scatter(real(data.egs.values(data.seig)), imag(data.egs.values(data.seig)), 'g' )
% hold off

set(handles.Eigenval_plot.Children,'ButtonDownFcn', {@Eigenval_plot_callback, handles})
%set(handles.Eigenval_plot.Children,'Selected', 'On')
replot_mode(handles)

function replot_mode(handles)
%get stored data
 data=get(handles.figure1,'UserData');
% set(handles.figure1,'CurrentAxes',handles.Eigenval_plot);
% scatter(real(data.egs.values), imag(data.egs.values), 'r');
%highlight selected data
% hold on
% scatter(real(data.egs.values(data.seig)), imag(data.egs.values(data.seig)), 'g' )
% hold off
%plot mode profile
set(handles.figure1,'CurrentAxes',handles.Mode_profile);
Visual.plotEig(data.egs,data.seig);

% --- Outputs from this function are returned to the command line.
function varargout = EigenGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on mouse press over axes background.
function Eigenval_plot_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Eigenval_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp(5);


% --- Executes during object creation, after setting all properties.
function Eigenval_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Eigenval_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Eigenval_plot

% --- Executes during object creation, after setting all properties.
function Mode_profile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mode_profile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Mode_profile


function [egs,lattice]=calculate(pump1,M,loss,alpha)      
%% PARAMETERS*************************************************
        %% PARAMETERS*************************************************
        edgepump=1;
        %pump1=S.pump1;
        if edgepump==1
        pump2=pump1;
        %loss=pump1*(44/224);
        else
            loss=pump1;
            pump2=0;
        end
        timelimit=500;
        %% CREATE EQUATIONS********************************************
        J=1;%normalize wrt J
        tr=100;%should be larger than 1
        sigma=24;
        %threshold=(1/tr)*(1/(tph*sigma)+1);
        eqna=ClassBdetuning();
        eqna.par.M=M;%detuning
        eqna.par.loss=loss;
        eqna.par.alpha=alpha;
        eqna.par.sigma=sigma;%
        eqna.par.pump=pump2;%
        eqna.par.tr=tr;%
        eqna.options.custom.Init_E='random';
        eqna.options.custom.Init_N='steady';
        eqna.initE=1;
        eqnb=eqna;
        eqnb.par.pump=pump1;
        if edgepump==0
         %now, we make one site lossless, the other gainless
         eqnb.par.loss=0;
         eqna.par.pump=0;
        end
        eqnb.par.M=-M;
        %% CREATE LATTICE***********************************************
        option=NNN.option_list;%get default option object
        option.custom.edges='baklava';%set edge option
        if edgepump==1
         option.custom.pump='edge';%pump edges only
        end
        %option.custom.BC='periodic1';
        %option.custom.pump='edge';%pump edges only
        lattice=NNN(eqna,eqnb,12,12,option);
        lattice.J=J;
        %% SOLVE********************************************************
        egs=Solver.calceig(lattice);
        
% --- Executes on slider movement.
function M_slider_Callback(hObject, eventdata, handles)
% hObject    handle to M_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.M=eventdata.Source.Value;
handles.Mtext.String=strcat('M= ',num2str(handles.M));
replot_eig(handles);

% --- Executes during object creation, after setting all properties.
function M_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function alpha_slider_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.alpha=eventdata.Source.Value;
handles.alphatext.String=strcat('alpha= ',num2str(handles.alpha));
replot_eig(handles);

% --- Executes during object creation, after setting all properties.
function alpha_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function pump_slider_Callback(hObject, eventdata, handles)
% hObject    handle to pump_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.pumptext,'String',strcat('pump= ',num2str(eventdata.Source.Value)));
replot_eig(handles);

% --- Executes during object creation, after setting all properties.
function pump_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pump_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function alphatext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alphatext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
hObject.String='alpha';


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over alpha_slider.
function alpha_slider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to alpha_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function loss_slider_Callback(hObject, eventdata, handles)
% hObject    handle to loss_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.losstext,'String',strcat('loss= ',num2str(eventdata.Source.Value)));
replot_eig(handles);

% --- Executes during object creation, after setting all properties.
function loss_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loss_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in calcbutton.
function calcbutton_Callback(hObject, eventdata, handles)
% hObject    handle to calcbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=get(handles.figure1,'UserData');
data.soln=Solver.calctime(data.lattice,1000);
set(handles.figure1,'CurrentAxes',handles.Mode_profile);
Visual.graphTimeAmp(data.soln);


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function parameters_Callback(hObject, eventdata, handles)
% hObject    handle to parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
