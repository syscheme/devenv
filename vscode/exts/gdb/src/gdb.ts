import { MI2DebugSession } from './mibase';
import { DebugSession, InitializedEvent, TerminatedEvent, StoppedEvent, OutputEvent, Thread, StackFrame, Scope, Source, Handles } from 'vscode-debugadapter';
import { DebugProtocol } from 'vscode-debugprotocol';
import { MI2 } from "./backend/mi2/mi2";
import { SSHArguments, ValuesFormattingMode } from './backend/backend';
// import { SSHArguments, GDBServerArguments, ValuesFormattingMode } from './backend/backend';
// import { isNullOrUndefined } from 'util';

export interface LaunchRequestArguments extends DebugProtocol.LaunchRequestArguments {
	cwd: string;
	target: string;
	gdbpath: string;
	env: any;
	debugger_args: string[];
	arguments: string;
	terminal: string;
	autorun: string[];
	ssh: SSHArguments;
	valuesFormatting: ValuesFormattingMode;
	printCalls: boolean;
	showDevDebugOutput: boolean;
}

export interface AttachRequestArguments extends DebugProtocol.AttachRequestArguments {
	cwd: string;
	target: string;
	gdbpath: string;
	env: any;
	debugger_args: string[];
	executable: string;
	remote: boolean;
	autorun: string[];
	ssh: SSHArguments;
// 	gdbserver: GDBServerArguments;
	valuesFormatting: ValuesFormattingMode;
	printCalls: boolean;
	showDevDebugOutput: boolean;
}

class GDBDebugSession extends MI2DebugSession {
	protected initializeRequest(response: DebugProtocol.InitializeResponse, args: DebugProtocol.InitializeRequestArguments): void {
		response.body.supportsHitConditionalBreakpoints = true;
		response.body.supportsConfigurationDoneRequest = true;
		response.body.supportsConditionalBreakpoints = true;
		response.body.supportsFunctionBreakpoints = true;
		response.body.supportsEvaluateForHovers = true;
		response.body.supportsSetVariable = true;
		response.body.supportsStepBack = true;
		this.sendResponse(response);
	}

	protected launchRequest(response: DebugProtocol.LaunchResponse, args: LaunchRequestArguments): void {
		this.miDebugger = new MI2(args.gdbpath || "gdb", ["-q", "--interpreter=mi2"], args.debugger_args, args.env);
		this.initDebugger();
		this.quit = false;
		this.attached = false;
		this.needContinue = false;
		this.isSSH = false;
		this.started = false;
		this.crashed = false;
		this.debugReady = false;
		this.setValuesFormattingMode(args.valuesFormatting);
		this.miDebugger.printCalls = !!args.printCalls;
		this.miDebugger.debugOutput = !!args.showDevDebugOutput;
		if (args.ssh !== undefined) {
			if (args.ssh.forwardX11 === undefined)
				args.ssh.forwardX11 = true;
			if (args.ssh.port === undefined)
				args.ssh.port = 22;
			if (args.ssh.x11port === undefined)
				args.ssh.x11port = 6000;
			if (args.ssh.x11host === undefined)
				args.ssh.x11host = "localhost";
			if (args.ssh.remotex11screen === undefined)
				args.ssh.remotex11screen = 0;
			this.isSSH = true;
			this.trimCWD = args.cwd.replace(/\\/g, "/");
			this.switchCWD = args.ssh.cwd;
			this.miDebugger.ssh(args.ssh, args.ssh.cwd, args.target, args.arguments, args.terminal, false).then(() => {
				if (args.autorun)
					args.autorun.forEach(command => {
						this.miDebugger.sendUserInput(command);
					});
				setTimeout(() => {
					this.miDebugger.emit("ui-break-done");
				}, 50);
				this.sendResponse(response);
				this.miDebugger.start().then(() => {
					this.started = true;
					if (this.crashed)
						this.handlePause(undefined);
				}, err => {
					this.sendErrorResponse(response, 100, `Failed to start MI Debugger: ${err.toString()}`);
				});
			}, err => {
				this.sendErrorResponse(response, 102, `Failed to SSH: ${err.toString()}`);
			});
		} else {
			this.miDebugger.load(args.cwd, args.target, args.arguments, args.terminal).then(() => {
				if (args.autorun)
					args.autorun.forEach(command => {
						this.miDebugger.sendUserInput(command);
					});
				setTimeout(() => {
					this.miDebugger.emit("ui-break-done");
				}, 50);
				this.sendResponse(response);
				this.miDebugger.start().then(() => {
					this.started = true;
					if (this.crashed)
						this.handlePause(undefined);
				}, err => {
					this.sendErrorResponse(response, 100, `Failed to Start MI Debugger: ${err.toString()}`);
				});
			}, err => {
				this.sendErrorResponse(response, 103, `Failed to load MI Debugger: ${err.toString()}`);
			});
		}
	}

//	log(type: string, msg: string) {
//		this.emit("msg", type, msg[msg.length - 1] == '\n' ? msg : (msg + "\n"));
//	}
//
//	private replaceVar(strc, name :string, value :string) :boolean {
//		if (isNullOrUndefined(name) || isNullOrUndefined(value) || isNullOrUndefined(strc.str))
//			return false;
//
//		var newstr= (strc.str.split('${' + name + '}').join(value));
//		var ret = (newstr != strc.str);
//		strc.str = newstr;
//		return ret;
//	}
//
//	protected applyEnvVars(args: AttachRequestArguments) : void {
//		if (isNullOrUndefined(args.env))
//			return;
//
//		this.log("INFO", `applyEnvVars`);
//		var finished = false;
//		while (!finished) {
//			finished = true;
//
//			for (var v in args.env) {
//				this.log("INFO", `var[${v}]=${args.env[v]} ...`);
//				var strc = {str:""};
//				strc.str =args.cwd; if (this.replaceVar(strc, v, args.env[v])) {finished = false; args.cwd=strc.str;}
//				strc.str =args.target; if (this.replaceVar(strc, v, args.env[v])) {finished = false; args.target=strc.str;}
//				strc.str =args.gdbpath; if (this.replaceVar(strc, v, args.env[v])) {finished = false; args.gdbpath=strc.str;}
//				strc.str =args.executable; if (this.replaceVar(strc, v, args.env[v])) {finished = false; args.executable=strc.str;}
//
//				if (args.gdbserver != undefined) {
//					strc.str =args.gdbserver.endpoint; if (this.replaceVar(strc, v, args.env[v])) {finished = false; args.gdbserver.endpoint=strc.str;}
//					strc.str =args.gdbserver.executable; if (this.replaceVar(strc, v, args.env[v])) {finished = false; args.gdbserver.executable=strc.str;}
//					strc.str =args.gdbserver.srcRootOfBuild; if (this.replaceVar(strc, v, args.env[v])) {finished = false; args.gdbserver.srcRootOfBuild=strc.str;}
//					strc.str =args.gdbserver.symbolDirs; if (this.replaceVar(strc, v, args.env[v])) {finished = false; args.gdbserver.symbolDirs=strc.str;}
//				}
//
//				if (args.autorun != undefined) {
//					for (var i = 0; i < args.autorun.length; i++) {
//						strc.str =args.autorun[i]; if (this.replaceVar(strc, v, args.env[v])) {finished = false; args.autorun[i]=strc.str;}
//					}
//				}
//
//				if (!finished)
//					this.log("INFO", `var[${v}]=${args.env[v]} applied`);
//			};
//
//		}
//	}

	protected attachRequest(response: DebugProtocol.AttachResponse, args: AttachRequestArguments): void {

//		this.applyEnvVars(args);

		this.miDebugger = new MI2(args.gdbpath || "gdb", ["-q", "--interpreter=mi2"], args.debugger_args, args.env);
		this.initDebugger();
		this.quit = false;
		this.attached = !args.remote;
		this.needContinue = true;
		this.isSSH = false;
		this.debugReady = false;
		this.setValuesFormattingMode(args.valuesFormatting);
		this.miDebugger.printCalls = !!args.printCalls;
		this.miDebugger.debugOutput = !!args.showDevDebugOutput;
		if (args.ssh !== undefined) {
			if (args.ssh.forwardX11 === undefined)
				args.ssh.forwardX11 = true;
			if (args.ssh.port === undefined)
				args.ssh.port = 22;
			if (args.ssh.x11port === undefined)
				args.ssh.x11port = 6000;
			if (args.ssh.x11host === undefined)
				args.ssh.x11host = "localhost";
			if (args.ssh.remotex11screen === undefined)
				args.ssh.remotex11screen = 0;
			this.isSSH = true;
			this.trimCWD = args.cwd.replace(/\\/g, "/");
			this.switchCWD = args.ssh.cwd;
			this.miDebugger.ssh(args.ssh, args.ssh.cwd, args.target, "", undefined, true).then(() => {
				if (args.autorun)
					args.autorun.forEach(command => {
						this.miDebugger.sendUserInput(command);
					});
				setTimeout(() => {
					this.miDebugger.emit("ui-break-done");
				}, 50);
				this.sendResponse(response);
			}, err => {
				this.sendErrorResponse(response, 102, `Failed to SSH: ${err.toString()}`);
			});
		} else {
//			if (args.gdbserver != undefined) {
//				if (isNullOrUndefined(args.gdbserver.endpoint))
//					args.gdbserver.endpoint =args.target;
//
//				if (isNullOrUndefined(args.gdbserver.executable))
//					args.gdbserver.executable =args.executable;
//
//				this.miDebugger.connect(args.cwd, args.gdbserver).then(() => {
//					this.log("INFO", `server connected: '${args.gdbserver}'`);
//
//					if (isNullOrUndefined(args.autorun))
//						args.autorun =[];
//
//					args.autorun.push("break main");
//					args.autorun.push("catch throw");
//					args.autorun.push("run");
//
//					args.autorun.forEach(command => { this.miDebugger.sendUserInput(command); });
//					this.sendResponse(response);
//				}, err => {
//					this.sendErrorResponse(response, 102, `Failed to attach: ${err.toString()}`);
//				});
//			} else
//
			if (args.remote) {
				this.miDebugger.connect(args.cwd, args.executable, args.target).then(() => {
					if (args.autorun)
						args.autorun.forEach(command => {
							this.miDebugger.sendUserInput(command);
						});
					this.sendResponse(response);
				}, err => {
					this.sendErrorResponse(response, 102, `Failed to attach: ${err.toString()}`);
				});
			} else {
				this.miDebugger.attach(args.cwd, args.executable, args.target).then(() => {
					if (args.autorun)
						args.autorun.forEach(command => {
							this.miDebugger.sendUserInput(command);
						});
					this.sendResponse(response);
				}, err => {
					this.sendErrorResponse(response, 101, `Failed to attach: ${err.toString()}`);
				});
			}
		}
	}
}

DebugSession.run(GDBDebugSession);
